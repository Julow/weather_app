$(BUILD_DIR)/index.html: REL_PATH=../statics/index.html

RES_DIR = statics
RES_TREE = $(patsubst $(RES_DIR)/%,$(BUILD_DIR)/%,)
RES_FILES = $(BUILD_DIR)/index.html

OCAML_OBJS = \
	$(OBJS_DIR)/srcs/WeatherData.cmo \
	$(OBJS_DIR)/srcs/Time.cmo \
	$(OBJS_DIR)/srcs/utils/LocalStorage.cmo \
	$(OBJS_DIR)/srcs/WeatherDataLoader.cmo \
	$(OBJS_DIR)/Component/Component.cmo \
	$(OBJS_DIR)/Component/ComponentTmpl_T.cmo \
	$(OBJS_DIR)/Component/ComponentTmpl_seq.cmo \
	$(OBJS_DIR)/Component/ComponentTmpl_switch.cmo \
	$(OBJS_DIR)/Component/ComponentTmpl.cmo \
	$(OBJS_DIR)/Component/Component_Html.cmo \
	$(OBJS_DIR)/srcs/main.cmo
OCAML_OBJ_TREE = $(OBJS_DIR)/srcs/utils $(OBJS_DIR)/srcs $(OBJS_DIR)/Component

OCAML_FIND = -package js_of_ocaml,js_of_ocaml.ppx,lwt,lwt.ppx -ppxopt lwt.ppx,-no-debug

$(OBJS_DIR)/Component/Component.cmo :
$(OBJS_DIR)/Component/Component.cmx :
$(OBJS_DIR)/Component/ComponentTmpl.cmo : $(OBJS_DIR)/Component/ComponentTmpl_switch.cmo $(OBJS_DIR)/Component/ComponentTmpl_seq.cmo $(OBJS_DIR)/Component/ComponentTmpl_T.cmo
$(OBJS_DIR)/Component/ComponentTmpl.cmx : $(OBJS_DIR)/Component/ComponentTmpl_switch.cmx $(OBJS_DIR)/Component/ComponentTmpl_seq.cmx $(OBJS_DIR)/Component/ComponentTmpl_T.cmx
$(OBJS_DIR)/Component/ComponentTmpl_T.cmo : $(OBJS_DIR)/Component/Component.cmo
$(OBJS_DIR)/Component/ComponentTmpl_T.cmx : $(OBJS_DIR)/Component/Component.cmx
$(OBJS_DIR)/Component/ComponentTmpl_seq.cmo : $(OBJS_DIR)/Component/ComponentTmpl_T.cmo
$(OBJS_DIR)/Component/ComponentTmpl_seq.cmx : $(OBJS_DIR)/Component/ComponentTmpl_T.cmx
$(OBJS_DIR)/Component/ComponentTmpl_switch.cmo : $(OBJS_DIR)/Component/ComponentTmpl_T.cmo
$(OBJS_DIR)/Component/ComponentTmpl_switch.cmx : $(OBJS_DIR)/Component/ComponentTmpl_T.cmx
$(OBJS_DIR)/Component/Component_Html.cmo : $(OBJS_DIR)/Component/ComponentTmpl_T.cmo $(OBJS_DIR)/Component/ComponentTmpl.cmo
$(OBJS_DIR)/Component/Component_Html.cmx : $(OBJS_DIR)/Component/ComponentTmpl_T.cmx $(OBJS_DIR)/Component/ComponentTmpl.cmx
$(OBJS_DIR)/srcs/Time.cmo :
$(OBJS_DIR)/srcs/Time.cmx :
$(OBJS_DIR)/srcs/WeatherData.cmo :
$(OBJS_DIR)/srcs/WeatherData.cmx :
$(OBJS_DIR)/srcs/WeatherDataLoader.cmo : $(OBJS_DIR)/srcs/WeatherData.cmo $(OBJS_DIR)/srcs/utils/LocalStorage.cmo
$(OBJS_DIR)/srcs/WeatherDataLoader.cmx : $(OBJS_DIR)/srcs/WeatherData.cmx $(OBJS_DIR)/srcs/utils/LocalStorage.cmx
$(OBJS_DIR)/srcs/main.cmo : $(OBJS_DIR)/srcs/WeatherDataLoader.cmo $(OBJS_DIR)/srcs/WeatherData.cmo $(OBJS_DIR)/srcs/Time.cmo $(OBJS_DIR)/Component/Component_Html.cmo $(OBJS_DIR)/Component/Component.cmo
$(OBJS_DIR)/srcs/main.cmx : $(OBJS_DIR)/srcs/WeatherDataLoader.cmx $(OBJS_DIR)/srcs/WeatherData.cmx $(OBJS_DIR)/srcs/Time.cmx $(OBJS_DIR)/Component/Component_Html.cmx $(OBJS_DIR)/Component/Component.cmx
$(OBJS_DIR)/srcs/utils/LocalStorage.cmo :
$(OBJS_DIR)/srcs/utils/LocalStorage.cmx :
