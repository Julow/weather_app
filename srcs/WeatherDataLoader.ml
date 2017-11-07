(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   WeatherDataLoader.ml                               :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: juloo <juloo@student.42.fr>                +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2017/06/10 14:03:29 by juloo             #+#    #+#             *)
(*   Updated: 2017/11/06 22:25:23 by juloo            ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

type cached = Uptodate of WeatherData.t | Outdated of WeatherData.t | Nodata

let cache_key = "weather_data_cache"
let cache_outdated = 15. *. 60. *. 1000.

let api_url = "http://api.wunderground.com/api/b08b95a1341330dd/astronomy/conditions/hourly/bestfct:1/q/48.8566,2.3522.json"

(* Get WeatherData from cache *)
let get_cached () =
	match LocalStorage.get cache_key with
	| Some json		->
		let cached_time, data = Js._JSON##parse json in
		if (new%js Js.date_now)##getTime -. cached_time < cache_outdated
			then Uptodate data
			else Outdated data
	| None			-> Nodata

let set_cached data =
	let now = (new%js Js.date_now)##getTime in
	Js._JSON##stringify (now, data)
	|> LocalStorage.set cache_key

exception RequestFailed of int
exception InvalidResponse

(* Get WeatherData from wunderground *)
(* May fail with RequestFailed (http code) or InvalidResponse *)
let load () =
	let process content =
		let data = WeatherData.of_object content in
		set_cached data;
		data
	in
	let open Lwt_xmlHttpRequest in
	match%lwt perform_raw XmlHttpRequest.JSON api_url with
	| { code=200; content; _ }	->
		Js.Opt.case content
			(fun () -> Lwt.fail InvalidResponse)
			(fun data -> Lwt.return (process data))
	| { code; _ }				-> Lwt.fail (RequestFailed code)
