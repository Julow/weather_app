(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   WeatherData.ml                                     :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: juloo <juloo@student.42.fr>                +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2017/06/10 14:03:17 by juloo             #+#    #+#             *)
(*   Updated: 2017/11/07 00:42:11 by juloo            ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

type location = {
	city			: string;
	state			: string;
	lon				: float;
	lat				: float;
	elevation		: float
}

type current = {
	timestamp		: int;
	(* location		: location; *)
	weather_string	: string;
	temperature		: int; (* celcius *)
	humidity		: int; (* percent *)
	wind_dir		: int; (* degree *)
	wind_speed		: int; (* km/h *)
	wind_gust		: int; (* km/h *)
	pressure		: int; (* hpa *)
	pressure_trend	: int;
	dewpoint		: int; (* celcius *)
	feelslike		: int; (* celcius *)
	(* visibility		: float; (* km *) *)
	condition		: string
}

let location_of_object o =
	{
		city		= Js.to_string o##.city;
		state		= Js.to_string o##.state;
		lon			= Js.parseFloat o##.longitude;
		lat			= Js.parseFloat o##.latitude;
		elevation	= Js.parseFloat o##.elevation
	}

let current_of_object o =
	{
		timestamp		= Js.parseInt o##.local_epoch_;
		(* location		= location_of_object o##.display_location_; *)
		weather_string	= Js.to_string o##.weather;
		temperature		= Js.parseInt o##.temp_c_;
		humidity		= Js.parseInt o##.relative_humidity_;
		wind_dir		= Js.parseInt o##.wind_degrees_;
		wind_speed		= Js.parseInt o##.wind_kph_;
		wind_gust		= Js.parseInt o##.wind_gust_kph_;
		pressure		= Js.parseInt o##.pressure_mb_;
		pressure_trend	= Js.parseInt o##.pressure_trend_;
		dewpoint		= Js.parseInt o##.dewpoint_c_;
		feelslike		= Js.parseInt o##.feelslike_c_;
		(* visibility		= Js.parseFloat o##.visibility_km_; *)
		condition		= Js.to_string o##.icon
	}

type hourly = {
	timestamp		: int;
	temperature		: int; (* celcius *)
	dewpoint		: int; (* celcius *)
	condition		: string;
	wind_speed		: int; (* km/h *)
	wind_dir		: int; (* degree *)
	humidity		: int; (* percent *)
	feelslike		: int; (* celcius *)
	pop				: int; (* percent *)
	snow			: int;
	pressure		: int (* hpa *)
}

let hourly_of_object o =
	{
		timestamp	= Js.parseInt o##._FCTTIME##.epoch;
		temperature	= Js.parseInt o##.temp##.metric;
		dewpoint	= Js.parseInt o##.dewpoint##.metric;
		condition	= Js.to_string o##.icon;
		wind_speed	= Js.parseInt o##.wspd##.metric;
		wind_dir	= Js.parseInt o##.wdir##.degrees;
		humidity	= Js.parseInt o##.humidity;
		feelslike	= Js.parseInt o##.feelslike##.metric;
		pop			= Js.parseInt o##.pop;
		snow		= Js.parseInt o##.snow##.metric;
		pressure	= Js.parseInt o##.mslp##.metric
	}

type moon_phase = {
	illuminated		: int; (* percent *)
	age				: int;
	hemisphere		: string;
	moonrise		: int * int; (* hour, minute *)
	moonset			: int * int (* hour, minute *)
}

type sun_phase = {
	sunrise			: int * int; (* hour, minute *)
	sunset			: int * int (* hour, minute *)
}

type t = {
	current			: current;
	hourly			: hourly array;
	moon			: moon_phase;
	sun				: sun_phase
}

let of_object o =
	let time_of_object o = Js.parseInt o##.hour, Js.parseInt o##.minute in
	let moon_phase_of_object o =
		{
			illuminated	= Js.parseInt o##.percentIlluminated;
			age			= Js.parseInt o##.ageOfMoon;
			hemisphere	= Js.to_string o##.hemisphere;
			moonrise	= time_of_object o##.moonrise;
			moonset		= time_of_object o##.moonset;
		}
	in
	let sun_phase_of_object o =
		{
			sunrise = time_of_object o##.sunrise;
			sunset = time_of_object o##.sunset
		}
	in
	{
		current	= current_of_object o##.current_observation_;
		hourly	= Array.map hourly_of_object (Js.to_array o##.hourly_forecast_);
		moon	= moon_phase_of_object o##.moon_phase_;
		sun		= sun_phase_of_object o##.sun_phase_
	}
