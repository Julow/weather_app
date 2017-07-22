(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   main.ml                                            :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: jaguillo <jaguillo@student.42.fr>          +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2017/05/16 17:23:44 by jaguillo          #+#    #+#             *)
(*   Updated: 2017/07/23 00:20:35 by juloo            ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

type 'a loop = 'a -> [ `Loop of 'a * 'a loop Lwt.t list ]

module TimeComp =
struct

	type t = Time.t

	let rec update_clock time t = `Loop (time, [next_sec ()])
	and next_sec () = Time.next_sec () |> Lwt.map update_clock

	let create time = time, [next_sec ()]

	let view : (t, t loop) Component_Html.tmpl =
		Component_Html.(
			e "div" [] [ text Time.to_string ]
		)

end

let (<|) f f' x = f (f' x)

let (%) = Printf.sprintf

let sub_update f f' =
	let rec update loop t =
		let `Loop (sub, tasks) = loop @@ f t in
		`Loop (f' t sub, map_tasks tasks)
	and map_tasks tasks = List.map (Lwt.map update) tasks in
	update, map_tasks

module WeatherComp =
struct

	type t = {
		data		: WeatherData.t;
		time		: TimeComp.t
	}

	let _time t = t.time
	let _with_time t time = { t with time }

	let time_comp_update, time_comp_tasks = sub_update _time _with_time

	let create data time =
		let time, tasks = TimeComp.create time in
		{ data; time }, time_comp_tasks tasks

	let set_data data t = `Loop ({ t with data }, [])

	let view : (t, t loop) Component_Html.tmpl = Component_Html.(
			e "div" [] [
				comp TimeComp.view _time time_comp_update;
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
		WeatherDataLoader.(match%lwt get_cached () with
		| Uptodate data		-> run (WeatherComp.create data time)
		| Outdated data		->
			let refresh_data =
				Lwt.map WeatherComp.set_data (load ())
			in
			let t, tasks = WeatherComp.create data time in
			run (t, refresh_data :: tasks)
		| Nodata			->
			let%lwt data = load () in
			run (WeatherComp.create data time))
	)
