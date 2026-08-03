extends GutTest
## v3.12 Object Mode: register packs/recipes, undo recipe, promote bridge

const Packs = preload("res://addons/flowkit/runtime/object_packs.gd")
const Recipes = preload("res://addons/flowkit/runtime/object_recipes.gd")
const Config = preload("res://addons/flowkit/runtime/object_config.gd")
const Bridge = preload("res://addons/flowkit/runtime/object_sheet_bridge.gd")


func test_register_pack_overrides_and_lists():
	Packs.clear_registered()
	var ok := Packs.register_pack({
		"id": "unit_test_pack",
		"name": "Unit Test Pack",
		"supported_types": ["Node2D"],
		"variables": {"ut": 1}
	})
	assert_true(ok)
	var p: Dictionary = Packs.get_pack("unit_test_pack")
	assert_eq(str(p.get("name", "")), "Unit Test Pack")
	var n := Node2D.new()
	add_child_autofree(n)
	var packs: Array = Packs.packs_for_node(n)
	var found := false
	for x in packs:
		if str(x.get("id", "")) == "unit_test_pack":
			found = true
	assert_true(found)
	Packs.unregister_pack("unit_test_pack")
	assert_true(Packs.get_pack("unit_test_pack").is_empty())


func test_apply_and_undo_recipe():
	var body := CharacterBody2D.new()
	add_child_autofree(body)
	assert_false(Config.is_pack_enabled(body, "platformer_2d"))
	Recipes.apply_recipe(body, "platformer_player")
	assert_true(Config.is_pack_enabled(body, "platformer_2d") or Config.is_pack_enabled(body, "health"))
	assert_true(body.is_in_group("player"))
	var undid := Recipes.undo_last_recipe(body)
	assert_eq(undid, "platformer_player")
	var again := Recipes.undo_last_recipe(body)
	assert_eq(again, "")


func test_combat_and_hitbox_packs_exist():
	assert_false(Packs.get_pack("hitbox_2d").is_empty())
	assert_false(Packs.get_pack("hurtbox_emit_died").is_empty())
	assert_false(Packs.get_pack("spawn_pool").is_empty())
	assert_false(Packs.get_pack("state_flags").is_empty())
	var area := Area2D.new()
	add_child_autofree(area)
	Packs.apply_pack(area, "hitbox_2d", {"damage": 7.0})
	assert_true(Config.is_pack_enabled(area, "hitbox_2d"))
	var rules: Array = Config.get_local_rules(area)
	assert_gt(rules.size(), 0)


func test_promote_rule_adds_emit_and_listener_dict():
	var n := Node2D.new()
	add_child_autofree(n)
	var rule := {
		"id": "death",
		"when": "hp_lte_0",
		"then": "queue_free",
		"params": {},
		"once": true,
		"enabled": true
	}
	var listener: Dictionary = Bridge.promote_rule(n, rule, true)
	assert_eq(str(listener.get("event_id", "")), "on_object_event")
	var rules: Array = Config.get_local_rules(n)
	var has_emit := false
	for r in rules:
		if r is Dictionary and str(r.get("then", "")) == "emit_object_event":
			has_emit = true
	assert_true(has_emit)


func test_hurtbox_recipe_exists():
	var r: Dictionary = Recipes.get_recipe("combat_enemy")
	assert_false(r.is_empty())
	var h: Dictionary = Recipes.get_recipe("hazard_hitbox")
	assert_false(h.is_empty())
