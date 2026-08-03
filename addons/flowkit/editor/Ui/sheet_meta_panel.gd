@tool
extends PanelContainer
class_name FKSheetMetaPanel
## Side panel for sheet variables + subsheet names.

signal meta_changed

var globals: FKEditorGlobals

var _vars_list: ItemList
var _name_edit: LineEdit
var _type_option: OptionButton
var _default_edit: LineEdit
var _sub_list: ItemList
var _sub_name_edit: LineEdit

const TYPES := ["int", "float", "bool", "string", "Variant"]

func setup(editor_globals: FKEditorGlobals) -> void:
	globals = editor_globals
	_build()
	refresh()

func _build() -> void:
	custom_minimum_size = Vector2(260, 0)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.14, 0.15, 0.18, 1)
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	add_theme_stylebox_override("panel", style)
	
	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 6)
	add_child(root)
	
	var title := Label.new()
	title.text = "Sheet Variables"
	title.add_theme_font_size_override("font_size", 13)
	root.add_child(title)
	
	_vars_list = ItemList.new()
	_vars_list.custom_minimum_size = Vector2(0, 100)
	_vars_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
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
	
	var sep := HSeparator.new()
	root.add_child(sep)
	
	var st := Label.new()
	st.text = "Subsheets"
	st.add_theme_font_size_override("font_size", 13)
	root.add_child(st)
	
	_sub_list = ItemList.new()
	_sub_list.custom_minimum_size = Vector2(0, 80)
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
	
	var hint := Label.new()
	hint.text = "Use s_name or bare name in expressions.\nCall Subsheet / For Each by name."
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.add_theme_color_override("font_color", Color(0.65, 0.7, 0.75))
	hint.add_theme_font_size_override("font_size", 10)
	root.add_child(hint)

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
			_sub_list.add_item("%s (%d actions)" % [s.subsheet_name, ac])

func _on_add_var() -> void:
	if globals == null:
		return
	var vname := _name_edit.text.strip_edges()
	if vname.is_empty() or not vname.is_valid_identifier():
		return
	var type_name: String = TYPES[_type_option.selected]
	var def_raw := _default_edit.text
	var default_val: Variant = _parse_default(def_raw, type_name)
	# Update existing
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
		globals.sheet_dirty = true
		refresh()
		meta_changed.emit()

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
