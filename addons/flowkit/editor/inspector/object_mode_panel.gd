@tool
extends VBoxContainer
class_name FKObjectModePanel
## Object Mode: packs, recipes, property binds. Writes flowkit_object + behaviors.

var node: Node = null
var registry: FKRegistry = null
var editor_interface: EditorInterface = null

var _packs_box: VBoxContainer
var _options_box: VBoxContainer
var _recipes_box: VBoxContainer
var _binds_box: VBoxContainer
var _rules_label: Label
var _pack_checks: Dictionary = {}
var _bind_var: LineEdit
var _bind_path: LineEdit
var _bind_max: LineEdit


func setup(p_node: Node, p_registry: FKRegistry, p_ei: EditorInterface) -> void:
	node = p_node
	registry = p_registry
	editor_interface = p_ei
	_rebuild()


func _ready() -> void:
	if _packs_box == null:
		_build_shell()


func _build_shell() -> void:
	add_theme_constant_override("separation", 6)
	var title := Label.new()
	title.text = "Object Mode"
	title.add_theme_font_size_override("font_size", 14)
	add_child(title)
	var hint := Label.new()
	hint.text = "Packs & recipes: build gameplay without the event sheet."
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.add_theme_font_size_override("font_size", 10)
	hint.add_theme_color_override("font_color", Color(0.65, 0.7, 0.75))
	add_child(hint)
	
	var rec_lab := Label.new()
	rec_lab.text = "Recipes (one-click)"
	rec_lab.add_theme_font_size_override("font_size", 12)
	add_child(rec_lab)
	_recipes_box = VBoxContainer.new()
	add_child(_recipes_box)
	
	var packs_lab := Label.new()
	packs_lab.text = "Packs"
	packs_lab.add_theme_font_size_override("font_size", 12)
	add_child(packs_lab)
	_packs_box = VBoxContainer.new()
	add_child(_packs_box)
	
	var opt_lab := Label.new()
	opt_lab.text = "Pack options"
	opt_lab.add_theme_font_size_override("font_size", 12)
	add_child(opt_lab)
	_options_box = VBoxContainer.new()
	add_child(_options_box)
	
	var bind_lab := Label.new()
	bind_lab.text = "Property binds (var → ProgressBar/Label)"
	bind_lab.add_theme_font_size_override("font_size", 12)
	add_child(bind_lab)
	_binds_box = VBoxContainer.new()
	add_child(_binds_box)
	var brow := HBoxContainer.new()
	add_child(brow)
	_bind_var = LineEdit.new()
	_bind_var.placeholder_text = "var (hp)"
	_bind_var.custom_minimum_size = Vector2(60, 0)
	brow.add_child(_bind_var)
	_bind_max = LineEdit.new()
	_bind_max.placeholder_text = "max_var"
	_bind_max.custom_minimum_size = Vector2(60, 0)
	brow.add_child(_bind_max)
	_bind_path = LineEdit.new()
	_bind_path.placeholder_text = "NodePath e.g. UI/HPBar"
	_bind_path.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	brow.add_child(_bind_path)
	var badd := Button.new()
	badd.text = "Bind"
	badd.pressed.connect(_on_add_bind)
	brow.add_child(badd)
	
	_rules_label = Label.new()
	_rules_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_rules_label.add_theme_font_size_override("font_size", 10)
	_rules_label.add_theme_color_override("font_color", Color(0.7, 0.75, 0.8))
	add_child(_rules_label)


func _rebuild() -> void:
	if _packs_box == null:
		_build_shell()
	_rebuild_recipes()
	for c in _packs_box.get_children():
		c.queue_free()
	_pack_checks.clear()
	if node == null:
		return
	for pack in FKObjectPacks.packs_for_node(node):
		var pid: String = str(pack.get("id", ""))
		var row := HBoxContainer.new()
		_packs_box.add_child(row)
		var cb := CheckBox.new()
		cb.text = str(pack.get("name", pid))
		cb.tooltip_text = str(pack.get("description", ""))
		cb.button_pressed = FKObjectConfig.is_pack_enabled(node, pid)
		cb.toggled.connect(_on_pack_toggled.bind(pid))
		row.add_child(cb)
		_pack_checks[pid] = cb
	_rebuild_options()
	_rebuild_binds()
	_refresh_rules_label()


func _rebuild_recipes() -> void:
	if _recipes_box == null:
		return
	for c in _recipes_box.get_children():
		c.queue_free()
	if node == null:
		return
	var recipes := FKObjectRecipes.recipes_for_node(node)
	if recipes.is_empty():
		var empty := Label.new()
		empty.text = "(no recipes for this node type)"
		empty.add_theme_font_size_override("font_size", 10)
		_recipes_box.add_child(empty)
		return
	for r in recipes:
		var btn := Button.new()
		btn.text = str(r.get("name", r.get("id", "")))
		btn.tooltip_text = str(r.get("description", ""))
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		var rid: String = str(r.get("id", ""))
		btn.pressed.connect(func():
			FKObjectRecipes.apply_recipe(node, rid)
			_rebuild()
			_notify()
		)
		_recipes_box.add_child(btn)


func _on_pack_toggled(on: bool, pack_id: String) -> void:
	if node == null:
		return
	if on:
		var opts := FKObjectConfig.get_pack_options(node, pack_id)
		FKObjectPacks.apply_pack(node, pack_id, opts)
	else:
		FKObjectPacks.remove_pack(node, pack_id)
	_rebuild_options()
	_refresh_rules_label()
	_notify()


func _rebuild_options() -> void:
	for c in _options_box.get_children():
		c.queue_free()
	if node == null:
		return
	for pack in FKObjectPacks.packs_for_node(node):
		var pid: String = str(pack.get("id", ""))
		if not FKObjectConfig.is_pack_enabled(node, pid):
			continue
		var opts := FKObjectConfig.get_pack_options(node, pid)
		var head := Label.new()
		head.text = "· " + str(pack.get("name", pid))
		head.add_theme_font_size_override("font_size", 11)
		_options_box.add_child(head)
		for od in pack.get("option_defs", []):
			if not (od is Dictionary):
				continue
			var oname: String = str(od.get("name", ""))
			var otype: String = str(od.get("type", "float")).to_lower()
			var cur = opts.get(oname, od.get("default", null))
			var line := HBoxContainer.new()
			_options_box.add_child(line)
			var lab := Label.new()
			lab.text = oname
			lab.custom_minimum_size = Vector2(100, 0)
			line.add_child(lab)
			match otype:
				"bool":
					var b := CheckBox.new()
					b.button_pressed = bool(cur)
					b.toggled.connect(func(v: bool):
						_set_option(pid, oname, v)
					)
					line.add_child(b)
				"float", "int":
					var sp := SpinBox.new()
					sp.min_value = 0
					sp.max_value = 99999
					sp.step = 1.0
					sp.allow_greater = true
					sp.value = float(cur) if cur != null else float(od.get("default", 0))
					sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
					sp.value_changed.connect(func(v: float):
						_set_option(pid, oname, int(v) if otype == "int" else v)
					)
					line.add_child(sp)
				_:
					var le := LineEdit.new()
					le.text = str(cur) if cur != null else ""
					le.size_flags_horizontal = Control.SIZE_EXPAND_FILL
					le.text_changed.connect(func(t: String):
						_set_option(pid, oname, t)
					)
					line.add_child(le)


func _set_option(pack_id: String, opt_name: String, value: Variant) -> void:
	if node == null:
		return
	var opts := FKObjectConfig.get_pack_options(node, pack_id)
	opts[opt_name] = value
	FKObjectPacks.apply_pack(node, pack_id, opts)
	_refresh_rules_label()
	_notify()


func _rebuild_binds() -> void:
	if _binds_box == null:
		return
	for c in _binds_box.get_children():
		c.queue_free()
	if node == null:
		return
	for b in FKObjectConfig.get_binds(node):
		if not (b is Dictionary):
			continue
		var row := HBoxContainer.new()
		_binds_box.add_child(row)
		var lab := Label.new()
		lab.text = "%s → %s" % [str(b.get("var", "")), str(b.get("path", ""))]
		lab.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(lab)
		var path_copy: String = str(b.get("path", ""))
		var del := Button.new()
		del.text = "×"
		del.pressed.connect(func():
			var next: Array = []
			for x in FKObjectConfig.get_binds(node):
				if x is Dictionary and str(x.get("path", "")) == path_copy:
					continue
				next.append(x)
			FKObjectConfig.set_binds(node, next)
			_rebuild_binds()
			_notify()
		)
		row.add_child(del)


func _on_add_bind() -> void:
	if node == null or _bind_path == null:
		return
	var path := _bind_path.text.strip_edges()
	var vname := _bind_var.text.strip_edges() if _bind_var else "hp"
	var maxv := _bind_max.text.strip_edges() if _bind_max else "max_hp"
	if path.is_empty():
		return
	if vname.is_empty():
		vname = "hp"
	if maxv.is_empty():
		maxv = "max_hp"
	FKObjectConfig.add_bind(node, vname, path, maxv)
	_bind_path.clear()
	_rebuild_binds()
	_notify()


func _refresh_rules_label() -> void:
	if _rules_label == null or node == null:
		return
	var rules := FKObjectConfig.get_local_rules(node)
	if rules.is_empty():
		_rules_label.text = "Local rules: (none)"
		return
	var bits: PackedStringArray = []
	for r in rules:
		if r is Dictionary:
			bits.append("%s → %s" % [str(r.get("when", "")), str(r.get("then", ""))])
	_rules_label.text = "Local rules: " + ", ".join(bits)


func _notify() -> void:
	if editor_interface:
		editor_interface.mark_scene_as_unsaved()
