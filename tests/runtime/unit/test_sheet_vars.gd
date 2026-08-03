extends GutTest

func test_build_sheet_var_defaults():
	var sheet := FKEventSheet.new()
	sheet.sheet_var_defs = [
		{"name": "score", "type": "int", "default": 10},
		{"name": "flag", "type": "bool", "default": "true"},
		{"name": "label", "type": "string", "default": "hi"},
	]
	var d := sheet.build_sheet_var_defaults()
	assert_eq(d["score"], 10)
	assert_eq(d["flag"], true)
	assert_eq(d["label"], "hi")


func test_find_subsheet():
	var sheet := FKEventSheet.new()
	var sub_script = load("res://addons/flowkit/resources/fk_subsheet.gd")
	var sub = sub_script.new()
	sub.subsheet_name = "MovePlayer"
	sheet.subsheets.append(sub)
	assert_not_null(sheet.find_subsheet("MovePlayer"))
	assert_null(sheet.find_subsheet("Nope"))


func test_event_flags_serialize():
	var e := FKEventUnit.new()
	e.enabled = false
	e.trigger_once = true
	e.once_while_true = true
	var d := e.serialize()
	assert_false(d["enabled"])
	assert_true(d["trigger_once"])
	var e2 := FKEventUnit.new()
	e2.deserialize(d)
	assert_false(e2.enabled)
	assert_true(e2.trigger_once)
	assert_true(e2.once_while_true)
