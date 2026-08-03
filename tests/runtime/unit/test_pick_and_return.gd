extends GutTest

func test_subsheet_return_defaults_null():
	var system = load("res://addons/flowkit/runtime/flowkit_system.gd").new()
	assert_true("subsheet_return" in system)
	assert_eq(system.subsheet_return, null)
	system.subsheet_return = 42
	assert_eq(system.subsheet_return, 42)

func test_picked_defaults_empty():
	var system = load("res://addons/flowkit/runtime/flowkit_system.gd").new()
	assert_eq(system.picked.size(), 0)
	assert_eq(system.picked_count, 0)
	system.picked = [Node.new()]
	system.picked_count = 1
	assert_eq(system.picked_count, 1)
	for n in system.picked:
		n.free()

func test_typed_param_normalize():
	assert_eq(FKTypedParamWidgets.normalize_type("Boolean"), "bool")
	assert_eq(FKTypedParamWidgets.normalize_type("INT"), "int")
	assert_eq(FKTypedParamWidgets.normalize_type("float"), "float")
	assert_eq(FKTypedParamWidgets.normalize_type("String"), "string")

func test_selection_manager_multi_row():
	var sel := FKSelectionManager.new()
	# Without real UI nodes, just verify API doesn't crash empty
	assert_false(sel.has_selection())
	assert_eq(sel.row_count(), 0)
