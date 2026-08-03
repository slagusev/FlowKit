extends GutTest
## Unit tests for FKBehaviorMeta multi-behavior node metadata.

func test_empty_node_has_no_behaviors():
	var n := Node.new()
	add_child_autofree(n)
	assert_eq(FKBehaviorMeta.get_behaviors(n).size(), 0)
	assert_false(FKBehaviorMeta.has_any(n))

func test_legacy_single_slot_reads_as_array():
	var n := Node.new()
	add_child_autofree(n)
	n.set_meta("flowkit_behavior", {"id": "platformer_movement", "inputs": {"speed": 100}})
	var list: Array = FKBehaviorMeta.get_behaviors(n)
	assert_eq(list.size(), 1)
	assert_eq(str(list[0].get("id", "")), "platformer_movement")
	assert_eq(list[0].get("inputs", {}).get("speed", 0), 100)

func test_add_or_replace_and_remove():
	var n := Node.new()
	add_child_autofree(n)
	FKBehaviorMeta.add_or_replace(n, "a", {"x": 1})
	FKBehaviorMeta.add_or_replace(n, "b", {"y": 2})
	assert_eq(FKBehaviorMeta.get_behaviors(n).size(), 2)
	# legacy mirror is first
	assert_true(n.has_meta("flowkit_behavior"))
	assert_eq(str(n.get_meta("flowkit_behavior").get("id", "")), "a")
	FKBehaviorMeta.add_or_replace(n, "a", {"x": 9})
	assert_eq(FKBehaviorMeta.get_behaviors(n).size(), 2)
	assert_eq(FKBehaviorMeta.get_behaviors(n)[0].get("inputs", {}).get("x", 0), 9)
	FKBehaviorMeta.remove_id(n, "a")
	assert_eq(FKBehaviorMeta.get_behaviors(n).size(), 1)
	assert_eq(str(FKBehaviorMeta.get_behaviors(n)[0].get("id", "")), "b")
	FKBehaviorMeta.clear_all(n)
	assert_eq(FKBehaviorMeta.get_behaviors(n).size(), 0)
	assert_false(n.has_meta("flowkit_behavior"))

func test_sheet_var_def_roundtrip():
	var d := FKSheetVarDef.from_dict({"name": "score", "type": "int", "default": "5"})
	assert_eq(d.var_name, "score")
	assert_eq(d.var_type, "int")
	var back := d.to_dict()
	assert_eq(str(back.get("name", "")), "score")
	assert_eq(FKSheetVarDef.coerce_default("12", "int"), 12)
	assert_eq(FKSheetVarDef.coerce_default("true", "bool"), true)

func test_provider_compat_node_match():
	assert_true(FKProviderCompat.is_node_compatible("CharacterBody2D", ["CharacterBody2D"]))
	assert_true(FKProviderCompat.is_node_compatible("CharacterBody2D", ["Node"]))
	assert_true(FKProviderCompat.is_node_compatible("CharacterBody2D", ["Node2D"]))
	assert_false(FKProviderCompat.is_node_compatible("Node2D", ["CharacterBody2D"]))
