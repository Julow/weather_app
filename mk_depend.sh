#!/bin/bash
# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    mk_depend.sh                                       :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: jaguillo <jaguillo@student.42.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2017/03/14 15:22:32 by jaguillo          #+#    #+#              #
#    Updated: 2017/05/16 17:27:32 by jaguillo         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

DEPEND_FILE=depend.mk

function mk_res_depend
{
	RES_DIR="$1"
	RES_TREE=`find "$RES_DIR" -mindepth 1 -type d | sort -r | tr '\n' ' '`

	RES_FILE_LIST=""
	for f in `find "$RES_DIR" -type f`
	do
		b='$(BUILD_DIR)'"/${f##$RES_DIR/}"
		if [[ "$f" == *".scss" ]]
		then
			b="${b%%.scss}.css"
			echo "$b: $f"
		else
			python -c 'import os
print("%s: REL_PATH=%s" % ("'"$b"'", os.path.relpath("'"$f"'", "'"${b%/*}"'")))
'
		fi
		RES_FILE_LIST="$RES_FILE_LIST $b"
	done
	echo
	echo 'RES_DIR = '"$RES_DIR"
	echo 'RES_TREE = $(patsubst $(RES_DIR)/%,$(BUILD_DIR)/%,'"$RES_TREE"')'
	echo 'RES_FILES ='"$RES_FILE_LIST"
	echo
}

function mk_ocaml_depend
{
	OCAML_DIR="$1"
	OCAML_FIND="$2"

	SRC_TREE=`find $OCAML_DIR -type d | sort -r`
	SOURCES=`find $OCAML_DIR -name '*.ml*' -type f`
	INCLUDES_FLAGS=`for d in $SRC_TREE; do echo "-I $d"; done`

	printf "OCAML_OBJS ="
	for obj in `ocamlfind ocamldep $OCAML_FIND -sort $INCLUDES_FLAGS $SOURCES \
			| tr ' ' '\n' | sed -e 's/\.ml$/.cmo/' -e 's/\.mli$/.cmi/'`
	do printf ' \\\n\t$(OBJS_DIR)/%s' "$obj"; done
	echo
	printf 'OCAML_OBJ_TREE ='
	for d in $SRC_TREE
	do printf ' $(OBJS_DIR)/%s' "$d"; done
	echo; echo
	echo 'OCAML_FIND = '"$OCAML_FIND"
	echo
	ocamlfind ocamldep $OCAML_FIND -one-line $INCLUDES_FLAGS $SOURCES \
		| sed -E 's#([^: ]+\.cm[oxi])#$(OBJS_DIR)/\1#g'
}

PACKAGES=`echo js_of_ocaml{,.ppx} lwt{,.ppx}`
PACKAGE_OPTS="-ppxopt lwt.ppx,-no-debug"

{
	mk_res_depend "statics"
	mk_ocaml_depend "srcs Component" "-package `echo $PACKAGES | tr ' ' ','` $PACKAGE_OPTS"
} > "$DEPEND_FILE"
