@tool
extends VBoxContainer
class_name FKObjectModePanel
## Object Mode: collapsible packs, recipes, binds, rules.

var node: Node = null
var registry: FKRegistry = null
var editor_interface: EditorInterface = null

var _status: Label
var _recipes_box: VBoxContainer
var _packs_box: VBoxContainer
var _options_box: VBoxContainer
var _binds_box: VBoxContainer
var _rules_list: VBoxContainer
var _rules_label: Label
var _pack_checks: Dictionary = {}
var _bind_var: LineEdit
var _bind_path: LineEdit
var _bind_max: LineEdit
var _when_opt: OptionButton
var _then_opt: OptionButton
var _rule_param: LineEdit

var _sec_recipes: VBoxContainer
var _sec_packs: VBoxContainer
var _sec_options: VBoxContainer
var _sec_binds: VBoxContainer
var _sec_rules: VBoxContainer

const WHEN_IDS := ["hp_lte_0", "var_lte", "var_gte", "body_in_group_player", "always", "on_ready_once"]
const THEN_IDS := [
	"queue_free", "print", "damage_self", "damage_overlapping_player",
	"add_sheet_var", "call_subsheet", "emit_object_event", "spawn_scene",
	"hide", "show", "set_var"
]


func setup(p_node: Node, p_registry: FKRegistry, p_ei: EditorInterface) -> void:
	node = p_node
	registry = p_registry
	editor_interface = p_ei
	_rebuild()


func _ready() -> void:
	if _packs_box == null:
		_build_shell()


func _section(title: String, open: bool = true) -> VBoxContainer:
	var wrap := VBoxContainer.new()
	wrap.add_theme_constant_override("separation", 4)
	add_child(wrap)
	var head := Button.new()
	head.toggle_mode = true
	head.button_pressed = open
	head.text = ("▼ " if open else "▶ ") + title
	head.alignment = HORIZONTAL_ALIGNMENT_LEFT
	head.flat = true
	wrap.add_child(head)
	var body := VBoxContainer.new()
	body.visible = open
	body.add_theme_constant_override("separation", 4)
	wrap.add_child(body)
	head.toggled.connect(func(on: bool):
		body.visible = on
		head.text = ("▼ " if on else "▶ ") + title
	)
	return body


func _build_shell() -> void:
	add_theme_constant_override("separation", 8)
	var title := Label.new()
	title.text = "Object Mode"
	title.add_theme_font_size_override("font_size", 14)
	add_child(title)
	var hint := Label.new()
	hint.text = "Gameplay without event sheet · recipes first, then packs."
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.add_theme_font_size_override("font_size", 10)
	hint.add_theme_color_override("font_color", Color(0.65, 0.7, 0.75))
	add_child(hint)
	_status = Label.new()
	_status.add_theme_font_size_override("font_size", 10)
	_status.add_theme_color_override("font_color", Color(0.5, 0.85, 0.6))
	add_child(_status)
	
	_sec_recipes = _section("Recipes (one-click)", true)
	_recipes_box = VBoxContainer.new()
	_sec_recipes.add_child(_recipes_box)
	
	_sec_packs = _section("Packs", true)
	_packs_box = VBoxContainer.new()
	_sec_packs.add_child(_packs_box)
	
	_sec_options = _section("Pack options", false)
	_options_box = VBoxContainer.new()
	_sec_options.add_child(_options_box)
	
	_sec_binds = _section("Property binds", false)
	_binds_box = VBoxContainer.new()
	_sec_binds.add_child(_binds_box)
	var brow := HBoxContainer.new()
	_sec_binds.add_child(brow)
	_bind_var = LineEdit.new()
	_bind_var.placeholder_text = "var"
	_bind_var.custom_minimum_size = Vector2(56, 0)
	_bind_var.text = "hp"
	brow.add_child(_bind_var)
	_bind_max = LineEdit.new()
	_bind_max.placeholder_text = "max"
	_bind_max.custom_minimum_size = Vector2(56, 0)
	_bind_max.text = "max_hp"
	brow.add_child(_bind_max)
	_bind_path = LineEdit.new()
	_bind_path.placeholder_text = "path e.g. UI/HPBar"
	_bind_path.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	brow.add_child(_bind_path)
	var badd := Button.new()
	badd.text = "Bind"
	badd.pressed.connect(_on_add_bind)
	brow.add_child(badd)
	
	_sec_rules = _section("Local rules", false)
	_rules_list = VBoxContainer.new()
	_sec_rules.add_child(_rules_list)
	var rrow := HBoxContainer.new()
	_sec_rules.add_child(rrow)
	_when_opt = OptionButton.new()
	for w in WHEN_IDS:
		_when_opt.add_item(w)
	rrow.add_child(_when_opt)
	_then_opt = OptionButton.new()
	for t in THEN_IDS:
		_then_opt.add_item(t)
	rrow.add_child(_then_opt)
	_rule_param = LineEdit.new()
	_rule_param.placeholder_text = "10 · score=5 · subsheet · died · res://enemy.tscn"
	_rule_param.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rrow.add_child(_rule_param)
	var radd := Button.new()
	radd.text = "+"
	radd.tooltip_text = "Add rule"
	radd.pressed.connect(_on_add_rule)
	rrow.add_child(radd)
	_rules_label = Label.new()
	_rules_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_rules_label.add_theme_font_size_override("font_size", 10)
	_rules_label.add_theme_color_override("font_color", Color(0.7, 0.75, 0.8))
	_sec_rules.add_child(_rules_label)


func _set_status(msg: String) -> void:
	if _status:
		_status.text = msg


func _rebuild() -> void:
	if _packs_box == null:
		_build_shell()
	_rebuild_recipes()
	for c in _packs_box.get_children():
		c.queue_free()
	_pack_checks.clear()
	if node == null:
		_set_status("")
		return
	_set_status("Node: %s (%s)" % [node.name, node.get_class()])
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
	_rebuild_rules()
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
		empty.text = "No recipes for %s" % node.get_class()
		empty.add_theme_font_size_override("font_size", 10)
		_recipes_box.add_child(empty)
		return
	var undo_row := HBoxContainer.new()
	_recipes_box.add_child(undo_row)
	var undo_btn := Button.new()
	undo_btn.text = "↩ Undo last recipe"
	undo_btn.tooltip_text = "Restore node snapshot from before last recipe apply"
	undo_btn.pressed.connect(func():
		var rid := FKObjectRecipes.undo_last_recipe(node)
		if rid.is_empty():
			_set_status("Nothing to undo")
		else:
			_set_status("Undid recipe: " + rid)
			_rebuild()
			_notify()
	)
	undo_row.add_child(undo_btn)
	for r in recipes:
		var row := HBoxContainer.new()
		_recipes_box.add_child(row)
		var btn := Button.new()
		btn.text = str(r.get("name", r.get("id", "")))
		btn.tooltip_text = str(r.get("description", ""))
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var rid: String = str(r.get("id", ""))
		btn.pressed.connect(func():
			FKObjectRecipes.apply_recipe(node, rid)
			_set_status("Applied recipe: " + rid)
			_rebuild()
			_notify()
		)
		row.add_child(btn)
		var rem := Button.new()
		rem.text = "×"
		rem.tooltip_text = "Remove this recipe packs/groups (best-effort)"
		rem.pressed.connect(func():
			FKObjectRecipes.remove_recipe(node, rid)
			_set_status("Removed recipe: " + rid)
			_rebuild()
			_notify()
		)
		row.add_child(rem)


func _on_pack_toggled(on: bool, pack_id: String) -> void:
	if node == null:
		return
	if on:
		FKObjectPacks.apply_pack(node, pack_id, FKObjectConfig.get_pack_options(node, pack_id))
		_set_status("Enabled pack: " + pack_id)
	else:
		FKObjectPacks.remove_pack(node, pack_id)
		_set_status("Disabled pack: " + pack_id)
	_rebuild_options()
	_rebuild_rules()
	_refresh_rules_label()
	_notify()


func _rebuild_options() -> void:
	for c in _options_box.get_children():
		c.queue_free()
	if node == null:
		return
	var any := false
	for pack in FKObjectPacks.packs_for_node(node):
		var pid: String = str(pack.get("id", ""))
		if not FKObjectConfig.is_pack_enabled(node, pid):
			continue
		any = true
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
			lab.custom_minimum_size = Vector2(96, 0)
			line.add_child(lab)
			match otype:
				"bool":
					var b := CheckBox.new()
					b.button_pressed = bool(cur)
					b.toggled.connect(func(v: bool): _set_option(pid, oname, v))
					line.add_child(b)
				"float", "int":
					var sp := SpinBox.new()
					sp.min_value = -999999
					sp.max_value = 999999
					sp.step = 1.0
					sp.allow_greater = true
					sp.allow_lesser = true
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
					le.text_changed.connect(func(t: String): _set_option(pid, oname, t))
					line.add_child(le)
	if not any:
		var empty := Label.new()
		empty.text = "Enable a pack to edit options."
		empty.add_theme_font_size_override("font_size", 10)
		_options_box.add_child(empty)


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
		_set_status("Bind needs a NodePath")
		return
	if vname.is_empty():
		vname = "hp"
	if maxv.is_empty():
		maxv = "max_hp"
	FKObjectConfig.add_bind(node, vname, path, maxv)
	_bind_path.clear()
	_set_status("Bound %s → %s" % [vname, path])
	_rebuild_binds()
	_notify()


func _rebuild_rules() -> void:
	if _rules_list == null:
		return
	for c in _rules_list.get_children():
		c.queue_free()
	if node == null:
		return
	var rules := FKObjectConfig.get_local_rules(node)
	for i in range(rules.size()):
		var r = rules[i]
		if not (r is Dictionary):
			continue
		var row := HBoxContainer.new()
		_rules_list.add_child(row)
		var en := CheckBox.new()
		en.button_pressed = bool(r.get("enabled", true))
		var idx := i
		en.toggled.connect(func(on: bool):
			var rs: Array = FKObjectConfig.get_local_rules(node)
			if idx < rs.size() and rs[idx] is Dictionary:
				rs[idx]["enabled"] = on
				FKObjectConfig.set_local_rules(node, rs)
				_notify()
		)
		row.add_child(en)
		var lab := Label.new()
		lab.text = "%s → %s" % [str(r.get("when", "")), str(r.get("then", ""))]
		lab.tooltip_text = str(r.get("params", {}))
		lab.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lab.add_theme_font_size_override("font_size", 10)
		row.add_child(lab)
		var promote := Button.new()
		promote.text = "↗"
		promote.tooltip_text = "Promote to sheet: ensure emit + On Object Event listener"
		var rule_copy: Dictionary = (r as Dictionary).duplicate(true)
		promote.pressed.connect(func():
			_promote_rule(rule_copy)
		)
		row.add_child(promote)
		var del := Button.new()
		del.text = "×"
		del.pressed.connect(func():
			var rs2: Array = FKObjectConfig.get_local_rules(node)
			if idx >= 0 and idx < rs2.size():
				rs2.remove_at(idx)
				FKObjectConfig.set_local_rules(node, rs2)
			_rebuild_rules()
			_refresh_rules_label()
			_notify()
		)
		row.add_child(del)


func _promote_rule(rule: Dictionary) -> void:
	if node == null or rule.is_empty():
		return
	var listener := FKObjectSheetBridge.promote_rule(node, rule, true)
	var root: Node = null
	if editor_interface:
		root = editor_interface.get_edited_scene_root()
	if root == null and node.get_tree() and node.get_tree().current_scene:
		root = node.get_tree().current_scene
	if root == null:
		root = node.owner if node.owner else node
	var ok := FKObjectSheetBridge.append_listener_to_scene_sheet(root, listener)
	if ok:
		_set_status("Promoted → sheet On Object Event + emit rule")
	else:
		_set_status("Promote failed (save sheet?) — emit rule may still be added")
	_rebuild_rules()
	_refresh_rules_label()
	_notify()


func _on_add_rule() -> void:
	if node == null or _when_opt == null or _then_opt == null:
		return
	var when_id: String = _when_opt.get_item_text(_when_opt.selected)
	var then_id: String = _then_opt.get_item_text(_then_opt.selected)
	var param_s: String = _rule_param.text.strip_edges() if _rule_param else ""
	var params: Dictionary = {}
	if not param_s.is_empty():
		if then_id == "call_subsheet":
			params["Name"] = param_s
		elif then_id == "emit_object_event":
			params["Event"] = param_s
		elif then_id == "spawn_scene":
			params["ScenePath"] = param_s
			params["Count"] = 1
		elif param_s.is_valid_float():
			params["Amount"] = float(param_s)
			params["Value"] = float(param_s)
		elif "=" in param_s:
			var parts := param_s.split("=", false, 1)
			params["Name"] = parts[0].strip_edges()
			params["Var"] = parts[0].strip_edges()
			var rhs := parts[1].strip_edges()
			params["Value"] = float(rhs) if rhs.is_valid_float() else rhs
		else:
			params["Name"] = param_s
			params["Message"] = param_s
			params["Event"] = param_s
	var rules: Array = FKObjectConfig.get_local_rules(node)
	var rid := "%s_%s_%d" % [when_id, then_id, rules.size()]
	rules.append({
		"id": rid,
		"enabled": true,
		"when": when_id,
		"then": then_id,
		"params": params,
		"once": when_id != "body_in_group_player" and when_id != "always"
	})
	FKObjectConfig.set_local_rules(node, rules)
	if _rule_param:
		_rule_param.clear()
	_set_status("Rule added: %s → %s" % [when_id, then_id])
	_rebuild_rules()
	_refresh_rules_label()
	_notify()


func _refresh_rules_label() -> void:
	if _rules_label == null or node == null:
		return
	var n := FKObjectConfig.get_local_rules(node).size()
	_rules_label.text = "%d rule(s) · param: 10 · score=5 · death" % n


func _notify() -> void:
	if editor_interface:
		editor_interface.mark_scene_as_unsaved()
