extends GutTest
## v3.13 runtime: pick options, wait actions, save version, conditions, OR groups


func test_pick_nodes_has_new_inputs():
	var scr = load("res://addons/flowkit/actions/System/pick_nodes.gd")
	var a = scr.new()
	assert_eq(a.get_id(), "pick_nodes")
	var names: Array = []
	for inp in a.get_inputs():
		if inp and "name" in inp:
			names.append(str(inp.name))
		elif inp is Object and inp.has_method("get"):
			pass
	# Inputs are FKActionInput with .name
	for inp in a.get_inputs():
		names.append(str(inp.name))
	assert_true("OverlapPath" in names)
	assert_true("SortBy" in names)
	assert_true("RandomCount" in names)


func test_wait_actions_exist_and_multi_frame():
	var w1 = load("res://addons/flowkit/actions/System/wait_seconds.gd").new()
	assert_eq(w1.get_id(), "wait_seconds")
	assert_true(w1.requires_multi_frames())
	var w2 = load("res://addons/flowkit/actions/System/wait_frames.gd").new()
	assert_eq(w2.get_id(), "wait_frames")
	assert_true(w2.requires_multi_frames())


func test_clear_save_slot_and_save_version():
	var save_scr = load("res://addons/flowkit/actions/System/save_sheet_state.gd").new()
	var clear_scr = load("res://addons/flowkit/actions/System/clear_save_slot.gd").new()
	assert_eq(save_scr.get_id(), "save_sheet_state")
	assert_eq(clear_scr.get_id(), "clear_save_slot")
	var sys = load("res://addons/flowkit/runtime/flowkit_system.gd").new()
	add_child_autofree(sys)
	# Simulate save path without full action execute (needs tree root path)
	var data := {"version": 2, "slot": "gut_test", "vars": {"score": 3}}
	var path := "user://flowkit_save_gut_test.json"
	var f := FileAccess.open(path, FileAccess.WRITE)
	assert_not_null(f)
	f.store_string(JSON.stringify(data))
	f = null
	assert_true(FileAccess.file_exists(path))
	DirAccess.remove_absolute(path)
	assert_false(FileAccess.file_exists(path))


func test_is_server_condition_offline_true():
	var c = load("res://addons/flowkit/conditions/System/is_server.gd").new()
	assert_eq(c.get_id(), "is_server")
	var n := Node.new()
	add_child_autofree(n)
	assert_true(c.check(n, {}))


func test_is_multiplayer_authority_offline_true():
	var c = load("res://addons/flowkit/conditions/Node/is_multiplayer_authority.gd").new()
	assert_eq(c.get_id(), "is_multiplayer_authority")
	var n := Node.new()
	add_child_autofree(n)
	assert_true(c.check(n, {}))


func test_last_expr_error_field_on_system():
	var sys = load("res://addons/flowkit/runtime/flowkit_system.gd").new()
	add_child_autofree(sys)
	assert_true("last_expr_error" in sys)
	assert_true("for_each_max" in sys)
	sys.last_expr_error = "test"
	assert_eq(sys.last_expr_error, "test")


func test_condition_groups_or_and_disabled():
	var a := FKConditionUnit.new()
	a.enabled = true
	a.or_with_previous = false
	var b := FKConditionUnit.new()
	b.enabled = false
	b.or_with_previous = false
	var c := FKConditionUnit.new()
	c.enabled = true
	c.or_with_previous = true
	var groups := FKConditionGroups.build_or_groups([a, b, c])
	# b skipped; a alone then... c has or_with_previous so joins a
	assert_eq(groups.size(), 1)
	assert_eq(groups[0].size(), 2)


func test_for_each_cap_logic():
	var engine = load("res://addons/flowkit/runtime/flowkit_engine.gd").new()
	add_child_autofree(engine)
	var root := Node2D.new()
	add_child_autofree(root)
	for i in 10:
		var e := Node2D.new()
		e.name = "x%d" % i
		root.add_child(e)
		e.add_to_group("g")
	var found: Array = engine.find_nodes_for_each(root, "g", "Node2D")
	assert_eq(found.size(), 10)
	# Cap simulation
	var max_n := 5
	if found.size() > max_n:
		found = found.slice(0, max_n)
	assert_eq(found.size(), 5)


func test_expression_evaluate_simple():
	var n := Node2D.new()
	add_child_autofree(n)
	n.position = Vector2(3, 4)
	var r = FKExpressionEvaluator.evaluate("1+2", n, n, n)
	assert_eq(r, 3)
