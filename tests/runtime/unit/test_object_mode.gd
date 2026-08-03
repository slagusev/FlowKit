extends GutTest

func test_object_config_default():
	var n := Node.new()
	add_child_autofree(n)
	var cfg := FKObjectConfig.get_config(n)
	assert_eq(int(cfg.get("version", 0)), 1)
	assert_false(FKObjectConfig.is_pack_enabled(n, "health"))

func test_health_pack_sets_vars_and_rule():
	var n := Node.new()
	add_child_autofree(n)
	FKObjectPacks.apply_pack(n, "health", {"max_hp": 50.0, "destroy_on_death": true})
	assert_true(FKObjectConfig.is_pack_enabled(n, "health"))
	assert_true(n.has_meta("flowkit_variables"))
	var vars: Dictionary = n.get_meta("flowkit_variables")
	assert_eq(float(vars.get("max_hp", 0)), 50.0)
	assert_eq(float(vars.get("hp", 0)), 50.0)
	var rules := FKObjectConfig.get_local_rules(n)
	assert_gt(rules.size(), 0)

func test_platformer_pack_adds_behavior():
	var body := CharacterBody2D.new()
	add_child_autofree(body)
	FKObjectPacks.apply_pack(body, "platformer_2d", {"speed": 150.0})
	var list := FKBehaviorMeta.get_behaviors(body)
	var found := false
	for b in list:
		if str(b.get("id", "")) == "platformer_movement":
			found = true
			assert_eq(float(b.get("inputs", {}).get("speed", 0)), 150.0)
	assert_true(found)
	FKObjectPacks.remove_pack(body, "platformer_2d")
	var after := FKBehaviorMeta.get_behaviors(body)
	for b in after:
		assert_ne(str(b.get("id", "")), "platformer_movement")

func test_hp_rule_queue_free_fires_once():
	var n := Node.new()
	add_child_autofree(n)
	FKObjectPacks.apply_pack(n, "health", {"max_hp": 10.0, "destroy_on_death": true})
	n.set_meta("flowkit_variables", {"hp": 0, "max_hp": 10})
	# Don't actually free during test — use print then instead
	FKObjectConfig.set_local_rules(n, [{
		"id": "t",
		"enabled": true,
		"when": "hp_lte_0",
		"then": "print",
		"params": {"Message": "dead"}
	}])
	FKObjectRules.process_node(n, null)
	var rt := FKObjectConfig.get_runtime(n)
	assert_true(bool(rt.get("fired", {}).get("t", false)))

func test_collectible_pack_behavior():
	var a := Area2D.new()
	add_child_autofree(a)
	FKObjectPacks.apply_pack(a, "collectible", {"points": 5.0})
	assert_true(FKObjectConfig.is_pack_enabled(a, "collectible"))
	var list := FKBehaviorMeta.get_behaviors(a)
	var found := false
	for b in list:
		if str(b.get("id", "")) == "collectible_pickup":
			found = true
			assert_eq(float(b.get("inputs", {}).get("points", 0)), 5.0)
	assert_true(found)

func test_recipe_platformer_player():
	var body := CharacterBody2D.new()
	add_child_autofree(body)
	FKObjectRecipes.apply_recipe(body, "platformer_player")
	assert_true(body.is_in_group("player"))
	assert_true(FKObjectConfig.is_pack_enabled(body, "platformer_2d"))
	assert_true(FKObjectConfig.is_pack_enabled(body, "health"))

func test_property_bind_updates_range():
	var n := Node.new()
	var bar := ProgressBar.new()
	bar.name = "HPBar"
	n.add_child(bar)
	add_child_autofree(n)
	n.set_meta("flowkit_variables", {"hp": 40.0, "max_hp": 100.0})
	FKObjectConfig.add_bind(n, "hp", "HPBar", "max_hp")
	FKObjectRules.process_node(n, null)
	assert_eq(bar.value, 40.0)
	assert_eq(bar.max_value, 100.0)
