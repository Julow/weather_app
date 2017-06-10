(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   LocalStorage.ml                                    :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: juloo <juloo@student.42.fr>                +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2017/06/10 17:14:36 by juloo             #+#    #+#             *)
(*   Updated: 2017/06/10 17:56:40 by juloo            ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

exception Not_supported

let storage =
	let unsupported () =
		object%js
			method getItem _ = raise Not_supported
			method setItem _ _ = raise Not_supported
			method key _ = raise Not_supported
			method removeItem _ = raise Not_supported
			val length = raise Not_supported
			method clear = raise Not_supported
		end
	in
	Js.Optdef.get Dom_html.window##.localStorage unsupported

let get key = storage##getItem (Js.string key) |> Js.Opt.to_option
let set key value = storage##setItem (Js.string key) value
let remove key = storage##removeItem (Js.string key)
let length () = storage##.length
let key n = storage##key n
let clear () = storage##clear
