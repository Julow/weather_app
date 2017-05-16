# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: juloo <juloo@student.42.fr>                +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2016/05/15 16:07:55 by juloo             #+#    #+#              #
#    Updated: 2017/05/16 17:22:53 by jaguillo         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

BUILD_DIR			= _build
OBJS_DIR			= _objs

BUILD_TARGET		= build
JS_OF_OCAML_TARGET	= $(BUILD_DIR)/app.js
OCAML_TARGET		= $(OBJS_DIR)/app.byte

CLEAN_FILES			=
FCLEAN_FILES		=

all: $(BUILD_TARGET)

include depend.mk

#
# Build extension
#

RELEASE_FILES		+= $(RES_FILES)
CLEAN_FILES			+= $(RES_FILES) $(RES_TREE)

$(BUILD_TARGET): $(JS_OF_OCAML_TARGET) $(RES_FILES) | $(BUILD_DIR)
.PHONY: $(BUILD_TARGET)

$(BUILD_DIR)/%.css: $(RES_DIR)/%.scss | $(RES_TREE)
	sassc -t compressed $^ $@ && $(PRINT_SUCCESS)

$(BUILD_DIR)/%: $(RES_DIR)/% | $(RES_TREE)
	ln -s $(REL_PATH) $@ && $(PRINT_SUCCESS)

$(RES_TREE): | $(BUILD_DIR)
	mkdir -p $@

#
# Build js file
#

JS_OF_OCAML_FLAGS	=

RELEASE_FILES		+= $(JS_OF_OCAML_TARGET)
CLEAN_FILES			+= $(JS_OF_OCAML_TARGET)

$(JS_OF_OCAML_TARGET): $(OCAML_TARGET) | $(BUILD_DIR)
	js_of_ocaml $(JS_OF_OCAML_FLAGS) +weak.js -o $@ $< && $(PRINT_SUCCESS)

#
# Build Ocaml bytecode
#

OCAML_FLAGS			+= -g $(addprefix -I ,$(OCAML_OBJ_TREE))
CLEAN_FILES			+= $(OCAML_TARGET) $(sort $(OCAML_OBJS) $(OCAML_OBJS:%.cmo=%.cmi)) $(OCAML_OBJ_TREE)

OCAMLC				:= ocamlfind ocamlc $(OCAML_FIND) -linkpkg

$(OCAML_TARGET): $(OCAML_OBJS)
	$(OCAMLC) $(OCAML_FLAGS) -o $@ $(filter %.cmo,$(OCAML_OBJS)) && $(PRINT_SUCCESS)

$(OBJS_DIR)/%.cmi: %.mli | $(OCAML_OBJ_TREE)
	$(OCAMLC) $(OCAML_FLAGS) -o $@ -c $< && $(PRINT_SUCCESS)
$(OBJS_DIR)/%.cmo: %.ml | $(OCAML_OBJ_TREE)
	$(OCAMLC) $(OCAML_FLAGS) -o $@ -c $< && $(PRINT_SUCCESS)

$(OCAML_OBJ_TREE): | $(OBJS_DIR)
	mkdir -p $@

i: $(filter %.cmi,$(OCAML_OBJS))
	OCAML_FLAGS=-i make $(filter %.cmo,$(OCAML_OBJS))

#
# Misc
#

PRINT_SUCCESS		= printf "\033[32m%s\033[0m\n" "$@"

$(BUILD_DIR) $(OBJS_DIR):
	mkdir $@

clean:
	-rm -fd $(CLEAN_FILES) $(BUILD_DIR) $(OBJS_DIR) 2> /dev/null || true

fclean: clean
	-rm -fd $(FCLEAN_FILES)

re: fclean
	make all

.SILENT:
.PHONY: all clean fclean re
