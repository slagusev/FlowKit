extends GutTest

func test_sheet_json_roundtrip_empty():
	var sheet := FKEventSheet.new()
	sheet.sheet_var_defs = [{"name": "score", "type": "int", "default": 0}] as Array[Dictionary]
	var json := FKSheetJsonIO.sheet_to_json(sheet)
	assert_true(json.contains("flowkit_sheet_json"))
	var back := FKSheetJsonIO.sheet_from_json(json)
	assert_not_null(back)
	assert_eq(back.sheet_var_defs.size(), 1)
	assert_eq(str(back.sheet_var_defs[0].get("name", "")), "score")

func test_event_breakpoint_serializes():
	var e := FKEventUnit.new()
	e.event_id = "on_ready"
	e.breakpoint_enabled = true
	var d := e.serialize()
	assert_true(d.get("breakpoint_enabled", false))
	var e2 := FKEventUnit.new()
	e2.deserialize(d)
	assert_true(e2.breakpoint_enabled)

func test_autocomplete_sheet_vars():
	var fake = {"sheet_var_defs": [{"name": "hp", "type": "int", "default": 1}]}
	var s := FKExpressionAutocomplete.suggestions_for("s_h", fake)
	var found := false
	for x in s:
		if str(x) == "s_hp":
			found = true
	assert_true(found)

func test_enabled_action_default():
	var a := FKActionUnit.new()
	assert_true(a.enabled)
	a.enabled = false
	var d := a.serialize()
	assert_false(d.get("enabled", true))
