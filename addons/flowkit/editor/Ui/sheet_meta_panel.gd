@tool
extends PanelContainer
class_name FKSheetMetaPanel
## Side panel: sheet variables, subsheets, and subsheet action list editing.

signal meta_changed
signal add_subsheet_action_requested(subsheet_index: int)
signal edit_subsheet_action_requested(subsheet_index: int, action_index: int)
signal retarget_subsheet_action_requested(subsheet_index: int, action_index: int)
signal rechoose_subsheet_action_requested(subsheet_index: int, action_index: int)

var globals: FKEditorGlobals

var _vars_list: ItemList
var _name_edit: LineEdit
var _type_option: OptionButton
var _default_edit: LineEdit
var _sub_list: ItemList
var _sub_name_edit: LineEdit
var _sub_actions_list: ItemList
var _sub_actions_label: Label

var _selected_sub_index: int = -1

const TYPES := ["int", "float", "bool", "string", "Variant"]

func setup(editor_globals: FKEditorGlobals) -> void:
	globals = editor_globals
	_build()
	refresh()

func _build() -> void:
	custom_minimum_size = Vector2(280, 0)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.14, 0.15, 0.18, 1)
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	add_theme_stylebox_override("panel", style)
	
	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 6)
	root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(root)
	
	var title := Label.new()
	title.text = "Sheet Variables"
	title.add_theme_font_size_override("font_size", 13)
	root.add_child(title)
	
	_vars_list = ItemList.new()
	_vars_list.custom_minimum_size = Vector2(0, 80)
	_vars_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_vars_list.item_selected.connect(_on_var_selected)
	root.add_child(_vars_list)
	
	var row := HBoxContainer.new()
	root.add_child(row)
	_name_edit = LineEdit.new()
	_name_edit.placeholder_text = "name"
	_name_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(_name_edit)
	_type_option = OptionButton.new()
	for t in TYPES:
		_type_option.add_item(t)
	row.add_child(_type_option)
	
	_default_edit = LineEdit.new()
	_default_edit.placeholder_text = "default"
	root.add_child(_default_edit)
	
	var btn_row := HBoxContainer.new()
	root.add_child(btn_row)
	var add_btn := Button.new()
	add_btn.text = "Add / Update"
	add_btn.pressed.connect(_on_add_var)
	btn_row.add_child(add_btn)
	var del_btn := Button.new()
	del_btn.text = "Delete"
	del_btn.pressed.connect(_on_del_var)
	btn_row.add_child(del_btn)
	
	root.add_child(HSeparator.new())
	
	var st := Label.new()
	st.text = "Subsheets"
	st.add_theme_font_size_override("font_size", 13)
	root.add_child(st)
	
	_sub_list = ItemList.new()
	_sub_list.custom_minimum_size = Vector2(0, 70)
	_sub_list.item_selected.connect(_on_sub_selected)
	root.add_child(_sub_list)
	
	_sub_name_edit = LineEdit.new()
	_sub_name_edit.placeholder_text = "subsheet name"
	root.add_child(_sub_name_edit)
	
	var srow := HBoxContainer.new()
	root.add_child(srow)
	var sadd := Button.new()
	sadd.text = "Add Subsheet"
	sadd.pressed.connect(_on_add_sub)
	srow.add_child(sadd)
	var sdel := Button.new()
	sdel.text = "Delete"
	sdel.pressed.connect(_on_del_sub)
	srow.add_child(sdel)
	
	_sub_actions_label = Label.new()
	_sub_actions_label.text = "Subsheet actions (select a subsheet)"
	_sub_actions_label.add_theme_font_size_override("font_size", 11)
	_sub_actions_label.add_theme_color_override("font_color", Color(0.7, 0.75, 0.8))
	root.add_child(_sub_actions_label)
	
	_sub_actions_list = ItemList.new()
	_sub_actions_list.custom_minimum_size = Vector2(0, 90)
	_sub_actions_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_sub_actions_list.item_activated.connect(_on_sub_action_activated)
	root.add_child(_sub_actions_list)
	
	var arow := HBoxContainer.new()
	root.add_child(arow)
	var aadd := Button.new()
	aadd.text = "Add Action"
	aadd.pressed.connect(_on_add_sub_action)
	arow.add_child(aadd)
	var aedit := Button.new()
	aedit.text = "Edit"
	aedit.pressed.connect(_on_edit_sub_action)
	arow.add_child(aedit)
	var atarget := Button.new()
	atarget.text = "Retarget"
	atarget.tooltip_text = "Pick a different target node for the selected action"
	atarget.pressed.connect(_on_retarget_sub_action)
	arow.add_child(atarget)
	var arechoose := Button.new()
	arechoose.text = "Change"
	arechoose.tooltip_text = "Pick a different action type (same or new node)"
	arechoose.pressed.connect(_on_rechoose_sub_action)
	arow.add_child(arechoose)
	var adel := Button.new()
	adel.text = "Remove"
	adel.pressed.connect(_on_del_sub_action)
	arow.add_child(adel)
	var aup := Button.new()
	aup.text = "↑"
	aup.pressed.connect(_on_move_sub_action.bind(-1))
	arow.add_child(aup)
	var adn := Button.new()
	adn.text = "↓"
	adn.pressed.connect(_on_move_sub_action.bind(1))
	arow.add_child(adn)
	
	root.add_child(HSeparator.new())
	var pl := Label.new()
	pl.text = "Subsheet parameters (selected)"
	pl.add_theme_font_size_override("font_size", 12)
	root.add_child(pl)
	_param_list = ItemList.new()
	_param_list.custom_minimum_size = Vector2(0, 56)
	root.add_child(_param_list)
	var prow := HBoxContainer.new()
	root.add_child(prow)
	_param_name_edit = LineEdit.new()
	_param_name_edit.placeholder_text = "param name"
	_param_name_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	prow.add_child(_param_name_edit)
	_param_default_edit = LineEdit.new()
	_param_default_edit.placeholder_text = "default"
	_param_default_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	prow.add_child(_param_default_edit)
	var padd := Button.new()
	padd.text = "Add Param"
	padd.pressed.connect(_on_add_param)
	prow.add_child(padd)
	var pdel := Button.new()
	pdel.text = "Del"
	pdel.pressed.connect(_on_del_param)
	prow.add_child(pdel)
	
	var hint := Label.new()
	hint.text = "Vars: s_name · Subsheet args: p_name\nCall Subsheet ArgsJson · For Each by name."
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.add_theme_color_override("font_color", Color(0.65, 0.7, 0.75))
	hint.add_theme_font_size_override("font_size", 10)
	root.add_child(hint)

var _param_list: ItemList
var _param_name_edit: LineEdit
var _param_default_edit: LineEdit

func refresh() -> void:
	if _vars_list == null or globals == null:
		return
	_vars_list.clear()
	for def in globals.sheet_var_defs:
		if def is Dictionary:
			_vars_list.add_item("%s : %s = %s" % [
				str(def.get("name", "")),
				str(def.get("type", "Variant")),
				str(def.get("default", ""))
			])
	_sub_list.clear()
	for s in globals.sheet_subsheets:
		if s != null and "subsheet_name" in s:
			var ac: int = 0
			if "actions" in s:
				ac = s.actions.size()
			var pc: int = 0
			if "parameters" in s and s.parameters is Array:
				pc = s.parameters.size()
			var label := "%s (%d)" % [s.subsheet_name, ac]
			if pc > 0:
				label += " p:%d" % pc
			_sub_list.add_item(label)
	_refresh_sub_actions()
	_refresh_params()

func _on_var_selected(index: int) -> void:
	if globals == null or index < 0 or index >= globals.sheet_var_defs.size():
		return
	var d: Dictionary = globals.sheet_var_defs[index]
	_name_edit.text = str(d.get("name", ""))
	var t: String = str(d.get("type", "Variant"))
	var ti := TYPES.find(t)
	_type_option.selected = ti if ti >= 0 else 4
	_default_edit.text = str(d.get("default", ""))

func _on_sub_selected(index: int) -> void:
	_selected_sub_index = index
	_refresh_sub_actions()
	_refresh_params()

func _refresh_params() -> void:
	if _param_list == null:
		return
	_param_list.clear()
	if globals == null or _selected_sub_index < 0 or _selected_sub_index >= globals.sheet_subsheets.size():
		return
	var sub = globals.sheet_subsheets[_selected_sub_index]
	if not ("parameters" in sub):
		return
	for p in sub.parameters:
		if p is Dictionary:
			_param_list.add_item("%s = %s" % [str(p.get("name", "")), str(p.get("default", ""))])

func _on_add_param() -> void:
	if globals == null or _selected_sub_index < 0:
		return
	var n := _param_name_edit.text.strip_edges() if _param_name_edit else ""
	if n.is_empty() or not n.is_valid_identifier():
		return
	var sub = globals.sheet_subsheets[_selected_sub_index]
	if not ("parameters" in sub):
		sub.parameters = [] as Array[Dictionary]
	var default_val: Variant = _param_default_edit.text if _param_default_edit else ""
	var found := false
	for i in range(sub.parameters.size()):
		var p: Dictionary = sub.parameters[i]
		if str(p.get("name", "")) == n:
			sub.parameters[i] = {"name": n, "type": "Variant", "default": default_val}
			found = true
			break
	if not found:
		sub.parameters.append({"name": n, "type": "Variant", "default": default_val})
	globals.sheet_dirty = true
	_param_name_edit.clear()
	_refresh_params()
	meta_changed.emit()

func _on_del_param() -> void:
	if globals == null or _selected_sub_index < 0 or _param_list == null:
		return
	var sel := _param_list.get_selected_items()
	if sel.is_empty():
		return
	var sub = globals.sheet_subsheets[_selected_sub_index]
	var idx: int = sel[0]
	if idx >= 0 and idx < sub.parameters.size():
		sub.parameters.remove_at(idx)
		globals.sheet_dirty = true
		_refresh_params()
		meta_changed.emit()

func _refresh_sub_actions() -> void:
	if _sub_actions_list == null:
		return
	_sub_actions_list.clear()
	if globals == null or _selected_sub_index < 0 or _selected_sub_index >= globals.sheet_subsheets.size():
		_sub_actions_label.text = "Subsheet actions (select a subsheet)"
		return
	var sub = globals.sheet_subsheets[_selected_sub_index]
	_sub_actions_label.text = "Actions in «%s»" % str(sub.subsheet_name)
	if not ("actions" in sub):
		return
	for i in range(sub.actions.size()):
		var act = sub.actions[i]
		if act == null:
			_sub_actions_list.add_item("[%d] (null)" % i)
			continue
		var label := str(act.action_id)
		if str(act.target_node) != "":
			label += " @ " + str(act.target_node)
		if not act.inputs.is_empty():
			label += " " + str(act.inputs)
		_sub_actions_list.add_item(label)

func _on_add_var() -> void:
	if globals == null:
		return
	var vname := _name_edit.text.strip_edges()
	if vname.is_empty() or not vname.is_valid_identifier():
		return
	var type_name: String = TYPES[_type_option.selected]
	var default_val: Variant = _parse_default(_default_edit.text, type_name)
	var found := false
	for i in range(globals.sheet_var_defs.size()):
		var d: Dictionary = globals.sheet_var_defs[i]
		if str(d.get("name", "")) == vname:
			globals.sheet_var_defs[i] = {"name": vname, "type": type_name, "default": default_val}
			found = true
			break
	if not found:
		globals.sheet_var_defs.append({"name": vname, "type": type_name, "default": default_val})
	globals.sheet_dirty = true
	refresh()
	meta_changed.emit()

func _on_del_var() -> void:
	if globals == null:
		return
	var sel := _vars_list.get_selected_items()
	if sel.is_empty():
		return
	var idx: int = sel[0]
	if idx >= 0 and idx < globals.sheet_var_defs.size():
		globals.sheet_var_defs.remove_at(idx)
		globals.sheet_dirty = true
		refresh()
		meta_changed.emit()

func _on_add_sub() -> void:
	if globals == null:
		return
	var n := _sub_name_edit.text.strip_edges()
	if n.is_empty():
		return
	for s in globals.sheet_subsheets:
		if s != null and "subsheet_name" in s and s.subsheet_name == n:
			return
	var sub_script = load("res://addons/flowkit/resources/fk_subsheet.gd")
	var sub = sub_script.new()
	sub.subsheet_name = n
	globals.sheet_subsheets.append(sub)
	globals.sheet_dirty = true
	_sub_name_edit.clear()
	refresh()
	_selected_sub_index = globals.sheet_subsheets.size() - 1
	_sub_list.select(_selected_sub_index)
	_refresh_sub_actions()
	meta_changed.emit()

func _on_del_sub() -> void:
	if globals == null:
		return
	var sel := _sub_list.get_selected_items()
	if sel.is_empty():
		return
	var idx: int = sel[0]
	if idx >= 0 and idx < globals.sheet_subsheets.size():
		globals.sheet_subsheets.remove_at(idx)
		_selected_sub_index = -1
		globals.sheet_dirty = true
		refresh()
		meta_changed.emit()

func _on_add_sub_action() -> void:
	if _selected_sub_index < 0:
		return
	add_subsheet_action_requested.emit(_selected_sub_index)

func _on_edit_sub_action() -> void:
	if _selected_sub_index < 0:
		return
	var sel := _sub_actions_list.get_selected_items()
	if sel.is_empty():
		return
	edit_subsheet_action_requested.emit(_selected_sub_index, sel[0])

func _on_retarget_sub_action() -> void:
	if _selected_sub_index < 0:
		return
	var sel := _sub_actions_list.get_selected_items()
	if sel.is_empty():
		return
	retarget_subsheet_action_requested.emit(_selected_sub_index, sel[0])

func _on_rechoose_sub_action() -> void:
	if _selected_sub_index < 0:
		return
	var sel := _sub_actions_list.get_selected_items()
	if sel.is_empty():
		return
	rechoose_subsheet_action_requested.emit(_selected_sub_index, sel[0])

func _on_sub_action_activated(index: int) -> void:
	if _selected_sub_index < 0:
		return
	edit_subsheet_action_requested.emit(_selected_sub_index, index)

func _on_del_sub_action() -> void:
	if globals == null or _selected_sub_index < 0:
		return
	var sel := _sub_actions_list.get_selected_items()
	if sel.is_empty():
		return
	var sub = globals.sheet_subsheets[_selected_sub_index]
	var ai: int = sel[0]
	if ai >= 0 and ai < sub.actions.size():
		sub.actions.remove_at(ai)
		globals.sheet_dirty = true
		_refresh_sub_actions()
		refresh()
		meta_changed.emit()

func _on_move_sub_action(delta: int) -> void:
	if globals == null or _selected_sub_index < 0:
		return
	var sel := _sub_actions_list.get_selected_items()
	if sel.is_empty():
		return
	var sub = globals.sheet_subsheets[_selected_sub_index]
	var ai: int = sel[0]
	var bi: int = ai + delta
	if bi < 0 or bi >= sub.actions.size():
		return
	var tmp = sub.actions[ai]
	sub.actions[ai] = sub.actions[bi]
	sub.actions[bi] = tmp
	globals.sheet_dirty = true
	_refresh_sub_actions()
	_sub_actions_list.select(bi)
	meta_changed.emit()

func get_sheet_var_names() -> PackedStringArray:
	var names: PackedStringArray = []
	if globals == null:
		return names
	for def in globals.sheet_var_defs:
		if def is Dictionary:
			var n: String = str(def.get("name", ""))
			if not n.is_empty():
				names.append(n)
	return names

func _parse_default(raw: String, type_name: String) -> Variant:
	raw = raw.strip_edges()
	match type_name:
		"int":
			return int(raw) if raw.is_valid_int() else 0
		"float":
			return float(raw) if raw.is_valid_float() else 0.0
		"bool":
			return raw.to_lower() in ["true", "1", "yes"]
		"string":
			return raw
		_:
			if raw.is_valid_int():
				return int(raw)
			if raw.is_valid_float():
				return float(raw)
			if raw.to_lower() in ["true", "false"]:
				return raw.to_lower() == "true"
			return raw
