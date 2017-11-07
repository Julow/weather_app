(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   main.ml                                            :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: jaguillo <jaguillo@student.42.fr>          +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2017/05/16 17:23:44 by jaguillo          #+#    #+#             *)
(*   Updated: 2017/11/07 23:13:35 by juloo            ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

open Component

module TimeComp =
struct

	type t = Time.t

	let rec update_clock time _ = time, [next_sec]
	and next_sec = Task (fun () -> Time.next_sec () |> Lwt.map update_clock)

	let create time = time, [next_sec]

end

let (~>) x _ = x
let (~~>) x _ _ = x

let (<|) f f' x = f (f' x)

let (%) = Printf.sprintf

let map_comp controler =
	let rec map_comp comp data =
		let data, tasks = comp data in
		data, List.map map_task tasks
	and map_controler comp data =
		controler (map_comp comp) data
	and map_task (Task t) =
		let t () = Lwt.map map_controler (t ()) in
		Task t
	in
	map_controler, List.map map_task

module WeatherComp =
struct

	type t = {
		data		: WeatherData.t;
		time		: TimeComp.t
	}

	let time_comp, time_comp_tasks = map_comp (fun time_comp t ->
			let time, tasks = time_comp t.time in
			{ t with time }, tasks
		)

	let create data time =
		let time, tasks = TimeComp.create time in
		{ data; time }, time_comp_tasks tasks

	let set_data data t = { t with data }, []

	(* open WeatherData *)
	(* open Component_Html *)

	let any_to_string x =
		(Obj.magic x : < toString : Js.js_string Js.t Js.meth > Js.t)##toString

	let view : (t, (t, t) controler) Component_Html.tmpl =
		let open Component_Html in
		let graph get (maxmin, minmax) length color =
			let width, height = 900, 200 in
			canvas width height (fun c t ->
				let rec get_minmax n m i =
					if i >= length then n, m
					else
						let d = get t i in
						get_minmax (min n d) (max m d) (i + 1)
				in
				let min, max = get_minmax maxmin minmax 0 in

				c##.lineWidth := 2.;
				c##.lineCap := Js.string "square";
				c##.textAlign := Js.string "center";
				c##.font := Js.string "10px Arial, sans-serif";
				c##.strokeStyle := Js.string color;

				let offset_x, offset_y = 10, 5 in
				let width = width - offset_x * 2
				and height = height - offset_y * 2 - 10 in

				let x i = i * width / (length - 1) + offset_x |> float
				(* and y i = height - (get t i - min) * height / (max - min) |> float in *)
				and y i = (max - get t i) * height / (max - min) + offset_y |> float in
				(* Draw graph *)
				c##beginPath;
				c##moveTo (x 0) (y 0);
				for i = 1 to length - 1 do
					c##lineTo (x i) (y i)
				done;
				(* Draw scale *)
				c##stroke;
				for i = 0 to length - 1 do
					c##fillText (any_to_string (get t i)) (x i) (float height +. 15.)
				done
			)
		in
		let graph f b l c = div [ _class "graph" ] [ graph f b l c ] in

		let open WeatherData in
		div [ _class "cont" ] [
			div [ _class "curr" ] [
				div [ _class "clock" ] [
					text (fun { time=(h,_,_); _ } -> string_of_int h);
					span [ _class "sep" ] [ _text ":" ];
					text (fun { time=(_,m,_); _ } -> string_of_int m);
				];

				div [ _class "stats_row" ] [
					div [] [
						b [] [ text (fun t -> "%d" % t.data.current.temperature) ];
						_text " °C"
					];
					div [] [
						b [] [ text (fun t -> "%d" % t.data.current.wind_speed) ];
						_text " km/h"
					]
				]
			];

			graph (fun t i -> t.data.hourly.(i).temperature) (0, 15) 15 "red";
			graph (fun t i -> t.data.hourly.(i).pop) (0, 30) 15 "blue";
			graph (fun t i -> t.data.hourly.(i).wind_speed) (5, 20) 15 "gray"
		]

end

let () =
	Lwt.async (fun () ->
		let%lwt _ = Lwt_js_events.onload () in
		let view = Component_Html.root Dom_html.document##.body WeatherComp.view in
		let run t = Component.run t view (fun t e -> e t) in
		let%lwt time = Time.now () in
		let open WeatherDataLoader in
		match get_cached () with
		| Uptodate data		-> run (WeatherComp.create data time)
		| Outdated data		->
			let refresh_data () = Lwt.map WeatherComp.set_data (load ()) in
			let t, tasks = WeatherComp.create data time in
			run (t, Task refresh_data :: tasks)
		| Nodata			->
			let%lwt data = load () in
			run (WeatherComp.create data time)
	)
