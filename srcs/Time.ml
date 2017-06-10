(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   Time.ml                                            :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: juloo <juloo@student.42.fr>                +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2017/06/10 14:04:44 by juloo             #+#    #+#             *)
(*   Updated: 2017/06/10 14:04:58 by juloo            ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

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
