extends RefCounted
class_name FKTypedParamWidgets
## Build type-aware editor widgets for expression / behavior parameters.
## Values are always stored as strings (expression language) for runtime eval.

signal value_changed(text: String)


static func normalize_type(type_name: String) -> String:
	var t := type_name.strip_edges().to_lower()
	match t:
		"bool", "boolean":
			return "bool"
		"int", "integer":
			return "int"
		"float", "real", "double", "number":
			return "float"
		"string", "str", "text":
			return "string"
		_:
			return "variant"


## Create a control that edits a param. Parent must free previous children.
## Returns the container (HBox/VBox). Call get_value_text() on meta "get_value".
static func build_editor(parent: Control, type_name: String, current: Variant, placeholder: String = "") -> Control:
	var kind := normalize_type(type_name)
	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(box)
	
	var mode_row := HBoxContainer.new()
	box.add_child(mode_row)
	var mode_btn := CheckBox.new()
	mode_btn.text = "Expression"
	mode_btn.tooltip_text = "When on, edit raw GDScript expression. When off, use typed control."
	mode_row.add_child(mode_btn)
	
	var typed_host := HBoxContainer.new()
	typed_host.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_child(typed_host)
	
	var expr := LineEdit.new()
	expr.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	expr.placeholder_text = placeholder if not placeholder.is_empty() else type_name
	expr.text = str(current) if current != null else ""
	box.add_child(expr)
	
	var use_expr := _looks_like_expression(str(current), kind)
	mode_btn.button_pressed = use_expr
	expr.visible = use_expr
	typed_host.visible = not use_expr
	
	var typed_ctrl: Control = null
	match kind:
		"bool":
			var cb := CheckBox.new()
			cb.text = "true"
			cb.button_pressed = _as_bool(current)
			typed_host.add_child(cb)
			typed_ctrl = cb
			cb.toggled.connect(func(on: bool):
				if not mode_btn.button_pressed:
					expr.text = "true" if on else "false"
					box.set_meta("_emit", true)
			)
		"int":
			var spin := SpinBox.new()
			spin.min_value = -999999
			spin.max_value = 999999
			spin.step = 1
			spin.value = float(_as_int(current))
			spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			typed_host.add_child(spin)
			typed_ctrl = spin
			spin.value_changed.connect(func(v: float):
				if not mode_btn.button_pressed:
					expr.text = str(int(v))
			)
		"float":
			var spinf := SpinBox.new()
			spinf.min_value = -999999.0
			spinf.max_value = 999999.0
			spinf.step = 0.01
			spinf.allow_greater = true
			spinf.allow_lesser = true
			spinf.value = _as_float(current)
			spinf.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			typed_host.add_child(spinf)
			typed_ctrl = spinf
			spinf.value_changed.connect(func(v: float):
				if not mode_btn.button_pressed:
					expr.text = str(v)
			)
		_:
			# string / variant — expression always
			mode_btn.button_pressed = true
			mode_btn.disabled = kind == "variant"
			expr.visible = true
			typed_host.visible = false
	
	mode_btn.toggled.connect(func(on: bool):
		expr.visible = on
		typed_host.visible = not on and typed_ctrl != null
		if not on and typed_ctrl != null:
			_sync_typed_from_expr(typed_ctrl, kind, expr.text)
		if on:
			expr.grab_focus()
	)
	
	box.set_meta("expr", expr)
	box.set_meta("mode_btn", mode_btn)
	box.set_meta("typed", typed_ctrl)
	box.set_meta("kind", kind)
	return box


static func get_value_text(editor: Control) -> String:
	if editor == null:
		return ""
	var expr: LineEdit = editor.get_meta("expr", null)
	var mode_btn: CheckBox = editor.get_meta("mode_btn", null)
	var typed: Control = editor.get_meta("typed", null)
	var kind: String = str(editor.get_meta("kind", "variant"))
	if mode_btn and mode_btn.button_pressed:
		return expr.text if expr else ""
	if typed == null:
		return expr.text if expr else ""
	match kind:
		"bool":
			return "true" if (typed as CheckBox).button_pressed else "false"
		"int":
			return str(int((typed as SpinBox).value))
		"float":
			return str((typed as SpinBox).value)
		_:
			return expr.text if expr else ""


static func _looks_like_expression(text: String, kind: String) -> bool:
	var t := text.strip_edges()
	if t.is_empty():
		return false
	if kind == "bool" and t in ["true", "false"]:
		return false
	if kind == "int" and t.is_valid_int():
		return false
	if kind == "float" and (t.is_valid_float() or t.is_valid_int()):
		return false
	# identifiers, ops, calls → expression mode
	return true


static func _as_bool(v: Variant) -> bool:
	if v is bool:
		return v
	var s := str(v).strip_edges().to_lower()
	return s in ["true", "1", "yes"]


static func _as_int(v: Variant) -> int:
	if v is int:
		return v
	if v is float:
		return int(v)
	var s := str(v).strip_edges()
	return int(s) if s.is_valid_int() else 0


static func _as_float(v: Variant) -> float:
	if v is float or v is int:
		return float(v)
	var s := str(v).strip_edges()
	if s.is_valid_float() or s.is_valid_int():
		return float(s)
	return 0.0


static func _sync_typed_from_expr(typed: Control, kind: String, text: String) -> void:
	match kind:
		"bool":
			(typed as CheckBox).button_pressed = _as_bool(text)
		"int":
			(typed as SpinBox).value = float(_as_int(text))
		"float":
			(typed as SpinBox).value = _as_float(text)
