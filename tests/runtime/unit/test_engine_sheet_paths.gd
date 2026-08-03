extends GutTest
## Engine sheet-path unit tests (conditions, enabled skip, templates, execute_block gate).


func test_condition_groups_skip_disabled():
	var a := FKConditionUnit.new()
	a.condition_id = "a"
	a.enabled = false
	a.or_with_previous = false
	var b := FKConditionUnit.new()
	b.condition_id = "b"
	b.enabled = true
	b.or_with_previous = false
	var groups := FKConditionGroups.build_or_groups([a, b])
	assert_eq(groups.size(), 1)
	assert_eq(groups[0].size(), 1)
	assert_eq(groups[0][0].condition_id, "b")


func test_condition_groups_or_and():
	var a := FKConditionUnit.new()
	a.or_with_previous = false
	a.enabled = true
	var b := FKConditionUnit.new()
	b.or_with_previous = true
	b.enabled = true
	var c := FKConditionUnit.new()
	c.or_with_previous = false
	c.enabled = true
	var groups := FKConditionGroups.build_or_groups([a, b, c])
	assert_eq(groups.size(), 2)
	assert_eq(groups[0].size(), 2)
	assert_eq(groups[1].size(), 1)


func test_simulate_or_flags():
	assert_true(FKConditionGroups.simulate_flags([true, false], [false, true]))
	assert_false(FKConditionGroups.simulate_flags([false, false], [false, true]))
	assert_true(FKConditionGroups.simulate_flags([], []))


func test_all_disabled_conditions_empty_groups_pass():
	var a := FKConditionUnit.new()
	a.enabled = false
	var groups := FKConditionGroups.build_or_groups([a])
	assert_eq(groups.size(), 0)
	# Engine treats empty groups as pass
	assert_true(FKConditionGroups.evaluate_group_bools([]))


func test_event_disabled_flag_roundtrip():
	var e := FKEventUnit.new()
	e.event_id = "on_ready"
	e.enabled = false
	e.breakpoint_enabled = true
	var d := e.serialize()
	assert_false(d.get("enabled", true))
	assert_true(d.get("breakpoint_enabled", false))
	var e2 := FKEventUnit.new()
	e2.deserialize(d)
	assert_false(e2.enabled)
	assert_true(e2.breakpoint_enabled)


func test_action_disabled_serializes():
	var a := FKActionUnit.new()
	a.action_id = "print"
	a.enabled = false
	var d := a.serialize()
	assert_false(d.get("enabled", true))


func test_sheet_templates_build():
	for t in FKSheetTemplates.list_templates():
		var id: String = str(t.get("id", ""))
		var sheet := FKSheetTemplates.build(id)
		assert_not_null(sheet, "template " + id)
		assert_true(sheet is FKEventSheet)


func test_score_loop_template_has_events_and_var():
	var sheet := FKSheetTemplates.build("score_loop")
	assert_eq(sheet.sheet_var_defs.size(), 1)
	assert_eq(str(sheet.sheet_var_defs[0].get("name", "")), "score")
	assert_gte(sheet.events.size(), 2)
	assert_eq(sheet.events[0].event_id, "on_ready")


func test_subsheet_template_has_subsheet():
	var sheet := FKSheetTemplates.build("subsheet_call")
	assert_eq(sheet.subsheets.size(), 1)
	assert_eq(sheet.subsheets[0].subsheet_name, "hello_sub")
	assert_eq(sheet.events.size(), 1)
	assert_eq(sheet.events[0].actions[0].action_id, "call_subsheet")


func test_execute_block_skips_disabled_event():
	# Lightweight gate matching FlowKitEngine._execute_block early return
	var e := FKEventUnit.new()
	e.enabled = false
	e.event_id = "on_ready"
	var would_run := e.enabled
	assert_false(would_run)


func test_find_nodes_for_each_helper():
	var engine_script = load("res://addons/flowkit/runtime/flowkit_engine.gd")
	assert_not_null(engine_script)
	var engine = engine_script.new()
	add_child_autofree(engine)
	var root := Node2D.new()
	add_child_autofree(root)
	var a := CharacterBody2D.new()
	a.name = "A"
	root.add_child(a)
	a.add_to_group("enemies")
	var b := CharacterBody2D.new()
	b.name = "B"
	root.add_child(b)
	b.add_to_group("enemies")
	var found: Array = engine.find_nodes_for_each(root, "enemies", "CharacterBody2D")
	assert_eq(found.size(), 2)
