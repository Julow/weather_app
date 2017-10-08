(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   main.ml                                            :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: jaguillo <jaguillo@student.42.fr>          +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2017/05/16 17:23:44 by jaguillo          #+#    #+#             *)
(*   Updated: 2017/10/08 20:29:04 by juloo            ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

open Component

module TimeComp =
struct

	type t = Time.t

	let rec update_clock time _ = time, [next_sec]
	and next_sec = Task (fun () -> Time.next_sec () |> Lwt.map update_clock)

	let create time = time, [next_sec]

	let view =
		Component_Html.(
			e "div" [] [ text Time.to_string ]
		)

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

	let view = Component_Html.(
			e "div" [] [
				comp TimeComp.view (fun t -> t.time) time_comp;
				e "div" [] [
					e "div" [] [
						text (fun t -> "%d°C" % t.data.current.temperature)
					];
					e "div" [] [
						text (fun t -> "%d km/h" % t.data.current.wind_speed)
					]
				]
			]
		)

end

let () =
	Lwt.async (fun () ->
		let%lwt _ = Lwt_js_events.onload () in
		let view = Component_Html.root WeatherComp.view Dom_html.document##.body in
		let run t = Component.run t view (fun t e -> e t) in
		let%lwt time = Time.now () in
		let open WeatherDataLoader in
		match%lwt get_cached () with
		| Uptodate data		-> run (WeatherComp.create data time)
		| Outdated data		->
			let refresh_data () = Lwt.map WeatherComp.set_data (load ()) in
			let t, tasks = WeatherComp.create data time in
			run (t, Task refresh_data :: tasks)
		| Nodata			->
			let%lwt data = load () in
			run (WeatherComp.create data time)
	)
