extends CanvasLayer
class_name FKDebugOverlay
## Runtime debug HUD showing recent FlowKit events / expression errors / sheet vars.

var _panel: PanelContainer
var _label: RichTextLabel
var _visible: bool = true
var _filter: String = ""  # empty = all; otherwise substring of kind or msg
var _paused: bool = false
var _last_snapshot: String = ""

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
	_panel.offset_right = 460
	_panel.offset_bottom = 260
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
	_label.custom_minimum_size = Vector2(440, 240)
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.add_child(_label)

func _process(_delta: float) -> void:
	if not _visible or _label == null or _paused:
		return
	var system = get_node_or_null("/root/FlowKitSystem")
	if system == null or not ("debug_log" in system):
		_label.text = "[b]FlowKit Debug[/b]\n(no system)"
		return
	if not system.debug_enabled:
		_panel.visible = false
		return
	_panel.visible = true
	var lines: PackedStringArray = [
		"[b]FlowKit Debug[/b] [i]F4 hide · F6 pause · F7 clear · F8 step · F9 cont[/i]"
	]
	if system.debug_step_mode:
		var wait_s := " WAITING" if system.debug_step_waiting else ""
		lines.append("[color=#f5b041]STEP MODE%s[/color] %s" % [wait_s, str(system.debug_step_label)])
	if "debug_active_event_id" in system and str(system.debug_active_event_id) != "":
		lines.append("[color=#f7dc6f]▶ %s[/color] action=%s block=%s" % [
			str(system.debug_active_event_id),
			str(system.debug_active_action_id),
			str(system.debug_active_block_id)
		])
	if "last_cond_fail" in system and str(system.last_cond_fail) != "":
		lines.append("[color=#ec7063]last fail:[/color] " + str(system.last_cond_fail))
	if "last_expr_error" in system and str(system.last_expr_error) != "":
		lines.append("[color=#e74c3c]expr:[/color] " + str(system.last_expr_error))
	# Picked / current summary
	if "picked_count" in system:
		var cur_n := ""
		if "current" in system and system.current is Node and is_instance_valid(system.current):
			cur_n = str(system.current.name)
		lines.append("[color=#85c1e9]pick:[/color] %s current=%s" % [str(system.picked_count), cur_n])
	# Top profiler entries (up to 5)
	if "profile_stats" in system and system.profile_stats is Dictionary and not system.profile_stats.is_empty():
		var entries: Array = []
		for k in system.profile_stats.keys():
			var st: Dictionary = system.profile_stats[k]
			entries.append({"id": k, "us": int(st.get("last_us", 0)), "n": int(st.get("count", 0)), "tot": int(st.get("total_us", 0))})
		entries.sort_custom(func(a, b): return a["us"] > b["us"])
		var top := mini(5, entries.size())
		var bits: PackedStringArray = []
		for i in range(top):
			bits.append("%s %dus×%d" % [entries[i]["id"], entries[i]["us"], entries[i]["n"]])
		lines.append("[color=#888]perf:[/color] " + ", ".join(bits))
	if not _filter.is_empty():
		lines.append("[color=#888]filter:[/color] %s" % _filter)
	var log_arr: Array = system.debug_log
	var start := maxi(0, log_arr.size() - 16)
	var shown := 0
	for i in range(start, log_arr.size()):
		var e: Dictionary = log_arr[i]
		var kind: String = str(e.get("kind", ""))
		var msg: String = str(e.get("msg", ""))
		if not _filter.is_empty():
			var hay := (kind + " " + msg).to_lower()
			if not (_filter.to_lower() in hay):
				continue
		var color := "aaaaaa"
		match kind:
			"event": color = "7dcea0"
			"cond_fail": color = "f5b041"
			"expr_error": color = "ec7063"
			"subsheet": color = "5dade2"
			"behavior": color = "bb8fce"
			"action": color = "85c1e9"
		var t_ms: int = int(e.get("t", 0))
		lines.append("[color=#666]%dms[/color] [color=#%s]%s[/color] %s" % [t_ms, color, kind, msg])
		shown += 1
	if shown == 0:
		lines.append("[color=#666](no log entries)[/color]")
	# Sheet vars snapshot
	if "current_sheet_vars" in system and system.current_sheet_vars is Dictionary and not system.current_sheet_vars.is_empty():
		lines.append("[color=#888]vars:[/color] " + str(system.current_sheet_vars))
	if "subsheet_params" in system and system.subsheet_params is Dictionary and not system.subsheet_params.is_empty():
		lines.append("[color=#888]params:[/color] " + str(system.subsheet_params))
	if "current" in system and system.current != null:
		lines.append("[color=#888]current:[/color] " + str(system.current.name if system.current is Node else system.current))
	_last_snapshot = "\n".join(lines)
	_label.text = _last_snapshot

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F4:
			_visible = not _visible
			_panel.visible = _visible
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_F6:
			_paused = not _paused
			if _paused and _label:
				_label.text = _last_snapshot + "\n[color=#f5b041]PAUSED[/color]"
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_F7:
			var system = get_node_or_null("/root/FlowKitSystem")
			if system and "debug_log" in system:
				system.debug_log.clear()
			if system and "last_cond_fail" in system:
				system.last_cond_fail = ""
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_F8:
			var system2 = get_node_or_null("/root/FlowKitSystem")
			if system2 and "debug_step_mode" in system2:
				system2.debug_step_mode = not system2.debug_step_mode
				if not system2.debug_step_mode:
					system2.debug_step_request_continue = true
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_F9:
			var system3 = get_node_or_null("/root/FlowKitSystem")
			if system3 and "debug_step_request_continue" in system3:
				system3.debug_step_request_continue = true
			get_viewport().set_input_as_handled()
