(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   main.ml                                            :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: jaguillo <jaguillo@student.42.fr>          +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2017/05/16 17:23:44 by jaguillo          #+#    #+#             *)
(*   Updated: 2017/06/10 00:35:24 by juloo            ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

module Time =
struct

	type t = int * int * int

	let now () =
		let now = new%js Js.date_now in
		Lwt.return (now##getHours, now##getMinutes, now##getSeconds)

	let next_sec () =
		let now = new%js Js.date_now in
		let t = float_of_int (1000 - now##getMilliseconds + 1) /. 1000. in
		Lwt_js.sleep t |> Lwt.map (fun () ->
			(now##getHours, now##getMinutes, now##getSeconds)
		)

	let to_string (h, m, s) = Printf.sprintf "%d:%02d:%02d" h m s

end

module WeatherData =
struct

	type t = int * int

	let dummy = -5, 72

	let temp (t, _) = t
	let wind (_, w) = w

end

module WeatherDataLoader =
struct

	type cached = Uptodate of WeatherData.t | Outdated of WeatherData.t | Nodata

	(* val get_cached : unit -> cached Lwt.t *)
	(* val load : unit -> WeatherData.t Lwt.t *)

end

type 'a loop = 'a -> [ `Loop of 'a * 'a loop Lwt.t list ]

module TimeComp =
struct
	type t = Time.t

	let rec update_clock time t = `Loop (time, [next_sec ()])
	and next_sec () = Time.next_sec () |> Lwt.map update_clock

	let create time = time, [next_sec ()]

	let view : (t, t loop) Component.tmpl' =
		Component.T.(
			e' "div" [ text Time.to_string ]
		)

end

let (<|) f f' x = f (f' x)

let (%) = Printf.sprintf

module WeatherComp =
struct

	type t = {
		data		: WeatherData.t;
		time		: TimeComp.t
	}

	let rec time_comp_update (`Loop (time, tasks)) t = `Loop ({ t with time }, time_comp_tasks tasks)
	and time_comp_tasks lst = List.map (Lwt.map (fun f t -> time_comp_update (f t.time) t)) lst

	let create data time =
		let time, tasks = TimeComp.create time in
		{ data; time }, time_comp_tasks tasks

	let _data t = t.data
	let _time t = t.time

	let view : (t, t loop) Component.tmpl' = Component.T.(
			e' "div" [
				comp TimeComp.view (fun _ time -> time) _time
					(fun _ time t -> time_comp_update (time t.time) t);
				e "div" [
					e "div" [
						text ((%) "%d°C" <| WeatherData.temp <| _data)
					];
					e "div" [
						text ((%) "%d km/h" <| WeatherData.wind <| _data)
					]
				]
			]
		)

end

let () =
	Lwt.async (fun () ->
		let%lwt _ = Lwt_js_events.onload () in
		let root = Component.create_root Dom_html.document##.body None in
		let%lwt time = Time.now () in
		let data = WeatherData.dummy in
		Component.run
			root
			(WeatherComp.create data time)
			WeatherComp.view
			(fun t e -> e t)
	)

