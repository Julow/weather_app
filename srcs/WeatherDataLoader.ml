(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   WeatherDataLoader.ml                               :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: juloo <juloo@student.42.fr>                +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2017/06/10 14:03:29 by juloo             #+#    #+#             *)
(*   Updated: 2017/06/10 18:58:54 by juloo            ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

type cached = Uptodate of WeatherData.t | Outdated of WeatherData.t | Nodata

let cache_key = "weather_data_cache"
let cache_outdated = 15. *. 60. *. 1000.

let api_url = "http://api.wunderground.com/api/b08b95a1341330dd/astronomy/conditions/hourly/bestfct:1/q/48.8566,2.3522.json"

let get_cached () =
	Lwt.return (match LocalStorage.get cache_key with
	| Some json		->
		let date, data = Js._JSON##parse json in
		if (new%js Js.date_now)##getTime -. date < cache_outdated
		then Uptodate data
		else Outdated data
	| None			-> Nodata)

let load () =
	let%lwt r = XmlHttpRequest.(perform_raw Text api_url) in
	let r = Js._JSON##parse r.XmlHttpRequest.content |> WeatherData.of_object in
	let now = (new%js Js.date_now)##getTime in
	Js._JSON##stringify (now, r) |> LocalStorage.set cache_key;
	Lwt.return r
