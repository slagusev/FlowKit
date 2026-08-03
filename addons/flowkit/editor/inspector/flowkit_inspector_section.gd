@tool
extends VBoxContainer
class_name FKInspectorSection

## FlowKit Inspector Section — multi-behavior UI with legacy single-slot compat.

var node: Node = null
var registry: FKRegistry = null
var editor_interface: EditorInterface = null

var header_container: HBoxContainer = null
var icon: TextureRect = null
var title_label: Label = null
var content_container: VBoxContainer = null

var behavior_section: VBoxContainer = null
var applied_list: ItemList = null
var behavior_dropdown: OptionButton = null
var add_btn: Button = null
var remove_btn: Button = null
var behavior_params_container: VBoxContainer = null
var available_behaviors: Array = []
var _editing_behavior_id: String = ""


func _ready() -> void:
	_build_ui()

func set_node(p_node: Node) -> void:
	node = p_node

func set_registry(p_registry: FKRegistry) -> void:
	registry = p_registry

func set_editor_interface(p_editor_interface: EditorInterface) -> void:
	editor_interface = p_editor_interface

func _build_ui() -> void:
	add_theme_constant_override("separation", 0)
	
	header_container = HBoxContainer.new()
	header_container.add_theme_constant_override("separation", 4)
	add_child(header_container)
	
	var top_separator: Control = Control.new()
	top_separator.custom_minimum_size = Vector2(0, 8)
	header_container.add_sibling(top_separator)
	header_container.move_to_front()
	
	content_container = VBoxContainer.new()
	content_container.add_theme_constant_override("separation", 4)
	add_child(content_container)
	
	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 4)
	margin.add_theme_constant_override("margin_right", 4)
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_bottom", 8)
	content_container.add_child(margin)
	
	var inner_vbox: VBoxContainer = VBoxContainer.new()
	inner_vbox.add_theme_constant_override("separation", 8)
	margin.add_child(inner_vbox)
	
	_build_behavior_section(inner_vbox)
	call_deferred("_set_header_icon")

func _build_behavior_section(parent: VBoxContainer) -> void:
	behavior_section = VBoxContainer.new()
	behavior_section.add_theme_constant_override("separation", 4)
	parent.add_child(behavior_section)
	
	var behavior_label: Label = Label.new()
	behavior_label.text = "Behaviors (multi)"
	behavior_label.add_theme_font_size_override("font_size", 13)
	behavior_section.add_child(behavior_label)
	
	applied_list = ItemList.new()
	applied_list.custom_minimum_size = Vector2(0, 64)
	applied_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	applied_list.item_selected.connect(_on_applied_selected)
	behavior_section.add_child(applied_list)
	
	var row := HBoxContainer.new()
	behavior_section.add_child(row)
	
	behavior_dropdown = OptionButton.new()
	behavior_dropdown.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(behavior_dropdown)
	
	add_btn = Button.new()
	add_btn.text = "Add"
	add_btn.tooltip_text = "Add or replace selected behavior on this node"
	add_btn.pressed.connect(_on_add_behavior)
	row.add_child(add_btn)
	
	remove_btn = Button.new()
	remove_btn.text = "Remove"
	remove_btn.pressed.connect(_on_remove_behavior)
	row.add_child(remove_btn)
	
	behavior_params_container = VBoxContainer.new()
	behavior_params_container.add_theme_constant_override("separation", 2)
	behavior_section.add_child(behavior_params_container)
	
	call_deferred("_populate_behaviors")

func _populate_behaviors() -> void:
	if not behavior_dropdown:
		return
	behavior_dropdown.clear()
	available_behaviors.clear()
	behavior_dropdown.add_item("(select behavior…)", 0)
	
	if not registry:
		_refresh_applied_list()
		return
	
	var node_class: String = node.get_class() if node else ""
	var idx: int = 1
	for provider in registry.behavior_providers:
		if not provider.has_method("get_supported_types"):
			continue
		var supported_types: Array = provider.get_supported_types()
		var is_supported: bool = false
		for supported_type in supported_types:
			if node_class == supported_type or (node and node.is_class(supported_type)):
				is_supported = true
				break
		if is_supported:
			var behavior_name: String = provider.get_name() if provider.has_method("get_name") else provider.get_id()
			behavior_dropdown.add_item(behavior_name, idx)
			available_behaviors.append(provider)
			idx += 1
	_refresh_applied_list()

func _refresh_applied_list() -> void:
	if not applied_list:
		return
	applied_list.clear()
	if not node:
		return
	var list: Array = FKBehaviorMeta.get_behaviors(node)
	for item in list:
		var bid := str(item.get("id", ""))
		var nice := bid
		for p in available_behaviors:
			if p.has_method("get_id") and p.get_id() == bid:
				nice = p.get_name() if p.has_method("get_name") else bid
				break
		applied_list.add_item(nice)
		applied_list.set_item_metadata(applied_list.item_count - 1, bid)
	if list.is_empty():
		_editing_behavior_id = ""
		_clear_behavior_params()
	elif _editing_behavior_id.is_empty():
		applied_list.select(0)
		_on_applied_selected(0)

func _on_applied_selected(index: int) -> void:
	if index < 0 or not applied_list:
		return
	var bid = applied_list.get_item_metadata(index)
	_editing_behavior_id = str(bid) if bid != null else ""
	if _editing_behavior_id.is_empty() or not node:
		_clear_behavior_params()
		return
	var list: Array = FKBehaviorMeta.get_behaviors(node)
	var inputs: Dictionary = {}
	for item in list:
		if str(item.get("id", "")) == _editing_behavior_id:
			if item.get("inputs", {}) is Dictionary:
				inputs = item.get("inputs")
			break
	var provider = registry.get_behavior(_editing_behavior_id) if registry else null
	if provider:
		_show_behavior_params(provider, inputs)
	else:
		_clear_behavior_params()

func _on_add_behavior() -> void:
	if not node or not behavior_dropdown:
		return
	var index: int = behavior_dropdown.selected
	if index <= 0:
		return
	var behavior_index: int = index - 1
	if behavior_index < 0 or behavior_index >= available_behaviors.size():
		return
	var provider = available_behaviors[behavior_index]
	var behavior_id: String = provider.get_id() if provider.has_method("get_id") else ""
	if behavior_id.is_empty():
		return
	var default_inputs: Dictionary = {}
	if provider.has_method("get_inputs"):
		for input_def in provider.get_inputs():
			var input_name: String = input_def.get("name", "")
			var default_value: Variant = input_def.get("default", "")
			if not input_name.is_empty():
				default_inputs[input_name] = default_value
	# Preserve existing inputs if re-adding same id
	for existing in FKBehaviorMeta.get_behaviors(node):
		if str(existing.get("id", "")) == behavior_id and existing.get("inputs", {}) is Dictionary:
			default_inputs = (existing.get("inputs") as Dictionary).duplicate(true)
			break
	FKBehaviorMeta.add_or_replace(node, behavior_id, default_inputs)
	_editing_behavior_id = behavior_id
	_refresh_applied_list()
	_show_behavior_params(provider, default_inputs)
	_notify_property_changed()

func _on_remove_behavior() -> void:
	if not node:
		return
	var bid := _editing_behavior_id
	if bid.is_empty() and applied_list and applied_list.get_selected_items().size() > 0:
		var idx: int = applied_list.get_selected_items()[0]
		bid = str(applied_list.get_item_metadata(idx))
	if bid.is_empty():
		# Remove all if nothing selected
		FKBehaviorMeta.clear_all(node)
	else:
		FKBehaviorMeta.remove_id(node, bid)
	_editing_behavior_id = ""
	_refresh_applied_list()
	_clear_behavior_params()
	_notify_property_changed()

func _clear_behavior_params() -> void:
	if not behavior_params_container:
		return
	for child in behavior_params_container.get_children():
		child.queue_free()

func _show_behavior_params(provider: Variant, current_inputs: Dictionary) -> void:
	_clear_behavior_params()
	if not provider or not provider.has_method("get_inputs"):
		return
	var inputs: Array = provider.get_inputs()
	if inputs.is_empty():
		return
	for input_def in inputs:
		var input_name: String = input_def.get("name", "")
		var input_type: String = input_def.get("type", "String")
		var default_value: Variant = input_def.get("default", "")
		var current_value: Variant = current_inputs.get(input_name, default_value)
		_add_behavior_param_row(input_name, input_type, current_value)

func _add_behavior_param_row(param_name: String, param_type: String, value: Variant) -> void:
	var row := VBoxContainer.new()
	row.add_theme_constant_override("separation", 2)
	behavior_params_container.add_child(row)
	row.set_meta("param_name", param_name)
	row.set_meta("param_type", param_type)
	
	var name_label: Label = Label.new()
	name_label.text = param_name.capitalize().replace("_", " ") + " (" + param_type + ")"
	row.add_child(name_label)
	
	var kind := FKTypedParamWidgets.normalize_type(param_type)
	match kind:
		"bool":
			var cb := CheckBox.new()
			cb.text = "enabled / true"
			cb.button_pressed = bool(value) if value is bool else str(value).to_lower() in ["true", "1", "yes"]
			cb.toggled.connect(func(on: bool):
				_on_behavior_param_changed(param_name, "true" if on else "false", param_type)
			)
			row.add_child(cb)
		"int", "float":
			var spin := SpinBox.new()
			spin.min_value = -999999.0
			spin.max_value = 999999.0
			spin.step = 1.0 if kind == "int" else 0.01
			spin.allow_greater = true
			spin.allow_lesser = true
			spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			if value is float or value is int:
				spin.value = float(value)
			elif str(value).is_valid_float():
				spin.value = float(str(value))
			spin.value_changed.connect(func(v: float):
				var s := str(int(v)) if kind == "int" else str(v)
				_on_behavior_param_changed(param_name, s, param_type)
			)
			row.add_child(spin)
		_:
			var value_edit: LineEdit = LineEdit.new()
			value_edit.text = str(value) if value != null else ""
			value_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			value_edit.placeholder_text = param_type
			value_edit.text_changed.connect(func(t: String):
				_on_behavior_param_changed(param_name, t, param_type)
			)
			row.add_child(value_edit)

func _on_behavior_param_changed(param_name: String, new_value: String, param_type: String) -> void:
	if not node or _editing_behavior_id.is_empty():
		return
	var list: Array = FKBehaviorMeta.get_behaviors(node)
	var kind := FKTypedParamWidgets.normalize_type(param_type)
	var typed_value: Variant = new_value
	match kind:
		"float":
			typed_value = float(new_value) if new_value.is_valid_float() else 0.0
		"int":
			typed_value = int(new_value) if new_value.is_valid_int() else 0
		"bool":
			typed_value = new_value.to_lower() in ["true", "1", "yes"]
	for i in range(list.size()):
		if str(list[i].get("id", "")) == _editing_behavior_id:
			var inputs: Dictionary = {}
			if list[i].get("inputs", {}) is Dictionary:
				inputs = (list[i].get("inputs") as Dictionary).duplicate(true)
			inputs[param_name] = typed_value
			list[i] = {"id": _editing_behavior_id, "inputs": inputs}
			break
	FKBehaviorMeta.set_behaviors(node, list)
	_notify_property_changed()

func _set_header_icon() -> void:
	if icon and is_inside_tree():
		var theme_icon: Texture2D = get_theme_icon("Script", "EditorIcons")
		if theme_icon:
			icon.texture = theme_icon

func _notify_property_changed() -> void:
	if editor_interface:
		editor_interface.mark_scene_as_unsaved()
