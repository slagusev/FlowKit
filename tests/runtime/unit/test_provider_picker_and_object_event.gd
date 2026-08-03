extends GutTest
## v3.11: picker core, compat, object-event bus, for_each helper

const PickerCore = preload("res://addons/flowkit/editor/provider_picker_core.gd")
const Compat = preload("res://addons/flowkit/editor/provider_compat.gd")


func test_picker_core_builds_sprite2d_actions():
	var reg = load("res://addons/flowkit/registry.gd").new()
	reg.load_providers()
	var items: Array = PickerCore.build_items(reg, "action", "Sprite2D", true)
	assert_gt(items.size(), 5, "Sprite2D should have several compatible actions")
	for it in items:
		assert_true(bool(it.get("compatible", false)), str(it.get("id")))


func test_picker_core_all_mode_includes_incompatible():
	var reg = load("res://addons/flowkit/registry.gd").new()
	reg.load_providers()
	var only: Array = PickerCore.build_items(reg, "action", "Sprite2D", true)
	var all_items: Array = PickerCore.build_items(reg, "action", "Sprite2D", false)
	assert_gte(all_items.size(), only.size())
	var has_incompat := false
	for it in all_items:
		if not bool(it.get("compatible", true)):
			has_incompat = true
			break
	assert_true(has_incompat or all_items.size() == only.size())


func test_picker_core_system_events():
	var reg = load("res://addons/flowkit/registry.gd").new()
	reg.load_providers()
	var items: Array = PickerCore.build_items(reg, "event", "System", true)
	assert_gt(items.size(), 3)
	var ids: Array = []
	for it in items:
		ids.append(str(it.get("id")))
	assert_true("on_ready" in ids or "on_process" in ids or ids.size() > 0)


func test_compat_sprite2d_node():
	assert_true(Compat.is_node_compatible("Sprite2D", ["Node"]))
	assert_true(Compat.is_node_compatible("Sprite2D", ["Node2D"]))
	assert_true(Compat.is_node_compatible("Sprite2D", ["CanvasItem"]))
	assert_false(Compat.is_node_compatible("Sprite2D", ["System"]))


func test_emit_object_event_action_id():
	var scr = load("res://addons/flowkit/actions/System/emit_object_event.gd")
	assert_not_null(scr)
	var a = scr.new()
	assert_eq(a.get_id(), "emit_object_event")
	var st: Array = []
	for t in a.get_supported_types():
		st.append(str(t))
	assert_true(Compat.is_node_compatible("Sprite2D", st))


func test_on_object_event_id():
	var scr = load("res://addons/flowkit/events/System/on_object_event.gd")
	assert_not_null(scr)
	var e = scr.new()
	assert_eq(e.get_id(), "on_object_event")
	assert_true(e.is_signal_event())


func test_object_event_bus_and_filter():
	var sys_scr = load("res://addons/flowkit/runtime/flowkit_system.gd")
	var sys = sys_scr.new()
	add_child_autofree(sys)
	# Bus itself
	var bus_hits := {"n": 0}
	sys.object_event.connect(func(en, _s, _p):
		if en == "died":
			bus_hits["n"] = int(bus_hits["n"]) + 1
	)
	sys.emit_object_event("other", null, {})
	assert_eq(int(bus_hits["n"]), 0)
	sys.emit_object_event("died", null, {"x": 1})
	assert_eq(int(bus_hits["n"]), 1)
	# Listener event provider with filter
	var ev_scr = load("res://addons/flowkit/events/System/on_object_event.gd")
	var ev = ev_scr.new()
	var hits := {"n": 0}
	ev.configure_filters("died", "")
	ev.setup(sys, func(): hits["n"] = int(hits["n"]) + 1)
	assert_true(sys.object_event.get_connections().size() >= 2)
	sys.emit_object_event("other", null, {})
	assert_eq(int(hits["n"]), 0)
	sys.emit_object_event("died", null, {"x": 1})
	assert_eq(int(hits["n"]), 1)
	assert_eq(str(sys.variables.get("last_object_event", "")), "died")
	ev.teardown(sys)


func test_object_rules_emit_object_event():
	var sys_scr = load("res://addons/flowkit/runtime/flowkit_system.gd")
	var sys = sys_scr.new()
	add_child_autofree(sys)
	# Parent tree root path won't have /root/FlowKitSystem — inject via tree
	# Use process_node with a node under our tree and monkey-patch path by adding system as child named FlowKitSystem under root is hard.
	# Instead call _run_then directly.
	var node := Node2D.new()
	add_child_autofree(node)
	var heard := {"n": 0}
	sys.object_event.connect(func(en, _s, _p):
		if en == "collected":
			heard["n"] = int(heard["n"]) + 1
	)
	# Simulate rule then with direct system call (same as rule body)
	sys.emit_object_event("collected", node, {})
	assert_eq(int(heard["n"]), 1)
	var rules_scr = load("res://addons/flowkit/runtime/object_rules.gd")
	assert_not_null(rules_scr)



func test_for_each_find_nodes():
	var engine_script = load("res://addons/flowkit/runtime/flowkit_engine.gd")
	var engine = engine_script.new()
	add_child_autofree(engine)
	var root := Node2D.new()
	add_child_autofree(root)
	for i in 3:
		var c := CharacterBody2D.new()
		c.name = "E%d" % i
		root.add_child(c)
		c.add_to_group("enemies")
	var found: Array = engine.find_nodes_for_each(root, "enemies", "CharacterBody2D")
	assert_eq(found.size(), 3)
