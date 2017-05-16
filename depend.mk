$(BUILD_DIR)/index.html: REL_PATH=../statics/index.html

RES_DIR = statics
RES_TREE = $(patsubst $(RES_DIR)/%,$(BUILD_DIR)/%,)
RES_FILES = $(BUILD_DIR)/index.html

OCAML_OBJS = \
	$(OBJS_DIR)/srcs/main.cmo
OCAML_OBJ_TREE = $(OBJS_DIR)/srcs

OCAML_FIND = -package js_of_ocaml,js_of_ocaml.ppx,lwt,lwt.ppx -ppxopt lwt.ppx,-no-debug

$(OBJS_DIR)/srcs/main.cmo :
$(OBJS_DIR)/srcs/main.cmx :
