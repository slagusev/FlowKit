extends CanvasLayer
class_name FKDebugOverlay
## Runtime debug HUD showing recent FlowKit events / expression errors.

var _panel: PanelContainer
var _label: RichTextLabel
var _visible: bool = true

func _ready() -> void:
	layer = 128
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()

func _build_ui() -> void:
	_panel = PanelContainer.new()
	_panel.anchor_left = 0
	_panel.anchor_top = 0
	_panel.anchor_right = 0
	_panel.anchor_bottom = 0
	_panel.offset_left = 8
	_panel.offset_top = 8
	_panel.offset_right = 420
	_panel.offset_bottom = 220
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_panel)
	
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.07, 0.1, 0.82)
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_right = 6
	style.corner_radius_bottom_left = 6
	style.content_margin_left = 8
	style.content_margin_top = 6
	style.content_margin_right = 8
	style.content_margin_bottom = 6
	_panel.add_theme_stylebox_override("panel", style)
	
	_label = RichTextLabel.new()
	_label.bbcode_enabled = true
	_label.fit_content = false
	_label.scroll_active = true
	_label.custom_minimum_size = Vector2(400, 200)
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.add_child(_label)

func _process(_delta: float) -> void:
	if not _visible or _label == null:
		return
	# Toggle with F3
	if Input.is_action_just_pressed("ui_text_completion_replace"):
		pass  # reserved
	var system = get_node_or_null("/root/FlowKitSystem")
	if system == null or not ("debug_log" in system):
		_label.text = "[b]FlowKit Debug[/b]\n(no system)"
		return
	if not system.debug_enabled:
		_panel.visible = false
		return
	_panel.visible = true
	var lines: PackedStringArray = ["[b]FlowKit Debug[/b] [i](F4 hide)[/i]"]
	var log_arr: Array = system.debug_log
	var start := maxi(0, log_arr.size() - 12)
	for i in range(start, log_arr.size()):
		var e: Dictionary = log_arr[i]
		var kind: String = str(e.get("kind", ""))
		var color := "aaaaaa"
		match kind:
			"event": color = "7dcea0"
			"cond_fail": color = "f5b041"
			"expr_error": color = "ec7063"
			"subsheet": color = "5dade2"
		lines.append("[color=#%s]%s[/color] %s" % [color, kind, str(e.get("msg", ""))])
	# Sheet vars snapshot
	if "current_sheet_vars" in system and system.current_sheet_vars is Dictionary and not system.current_sheet_vars.is_empty():
		lines.append("[color=#888]vars:[/color] " + str(system.current_sheet_vars))
	_label.text = "\n".join(lines)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F4:
			_visible = not _visible
			_panel.visible = _visible
			get_viewport().set_input_as_handled()
