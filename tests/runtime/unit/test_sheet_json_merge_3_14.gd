extends GutTest
## v3.14: JSON merge, command palette command ids, reload_sheets action id


func test_merge_sheets_appends_events_and_vars():
	var base := FKEventSheet.new()
	var base_vars: Array[Dictionary] = [{"name": "score", "type": "int", "default": 0}]
	base.sheet_var_defs = base_vars
	var e1 := FKEventUnit.new()
	e1.event_id = "on_ready"
	e1.block_id = "base_ready_1"
	base.events.append(e1)
	base.item_order.append({"type": "event", "index": 0})

	var incoming := FKEventSheet.new()
	var inc_vars: Array[Dictionary] = [
		{"name": "score", "type": "int", "default": 99},  # should not overwrite
		{"name": "lives", "type": "int", "default": 3},
	]
	incoming.sheet_var_defs = inc_vars
	var e2 := FKEventUnit.new()
	e2.event_id = "on_process"
	e2.block_id = "incoming_process"
	incoming.events.append(e2)
	incoming.item_order.append({"type": "event", "index": 0})

	var merged := FKSheetJsonIO.merge_sheets(base, incoming)
	assert_not_null(merged)
	assert_eq(merged.events.size(), 2, "merge should append events")
	assert_eq(merged.events[0].event_id, "on_ready")
	assert_eq(merged.events[1].event_id, "on_process")
	assert_true(str(merged.events[1].block_id) != "", "incoming event gets a block_id")
	var names: Array = []
	for v in merged.sheet_var_defs:
		if v is Dictionary:
			names.append(str(v.get("name", "")))
	assert_true("score" in names)
	assert_true("lives" in names)
	for v2 in merged.sheet_var_defs:
		if v2 is Dictionary and str(v2.get("name", "")) == "score":
			assert_eq(int(v2.get("default", -1)), 0)
			break


func test_merge_null_sides():
	var only := FKEventSheet.new()
	var e := FKEventUnit.new()
	e.event_id = "on_ready"
	only.events.append(e)
	assert_eq(FKSheetJsonIO.merge_sheets(null, only).events.size(), 1)
	assert_eq(FKSheetJsonIO.merge_sheets(only, null).events.size(), 1)
	assert_not_null(FKSheetJsonIO.merge_sheets(null, null))


func test_reload_sheets_action_id():
	var script = load("res://addons/flowkit/actions/System/reload_sheets.gd")
	assert_not_null(script)
	var a = script.new()
	assert_eq(a.get_id(), "reload_sheets")
	assert_true(a.get_supported_types().has("System"))


func test_command_palette_default_commands_include_merge():
	# Load via path so global class cache is not required (fresh scripts / headless).
	var script = load("res://addons/flowkit/editor/command_palette.gd")
	assert_not_null(script, "command_palette.gd must load")
	var palette = script.new()
	assert_true(palette.has_method("setup_default_commands"))
	palette.setup_default_commands()
	var cmds: Array = palette.get("_commands") if palette.get("_commands") != null else []
	# Access field after setup
	if cmds.is_empty() and "_commands" in palette:
		cmds = palette._commands
	# Fallback: call and read again
	if cmds.is_empty():
		cmds = palette._commands
	var ids: Array = []
	for c in cmds:
		ids.append(str(c.get("id", "")))
	assert_true(ids.size() > 0, "palette should register default commands")
	assert_true("import_json_merge" in ids)
	assert_true("hot_reload" in ids)
	assert_true("provider_browser" in ids)
	assert_true("new_event" in ids)
	palette.free()
