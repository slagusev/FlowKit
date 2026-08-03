extends RefCounted
class_name FKSheetTemplates
## Built-in event sheet templates for "New from Template" in the editor.


static func list_templates() -> Array:
	## [{id, name, description}]
	return [
		{
			"id": "blank",
			"name": "Blank Sheet",
			"description": "Empty sheet with optional starter score var."
		},
		{
			"id": "on_ready_print",
			"name": "On Ready → Print",
			"description": "System On Ready prints a hello message."
		},
		{
			"id": "score_loop",
			"name": "Score on Key",
			"description": "Sheet var score; Space key adds points via print."
		},
		{
			"id": "or_example",
			"name": "OR Conditions Example",
			"description": "Two conditions OR'd (keys A or B) then print."
		},
		{
			"id": "subsheet_call",
			"name": "Call Subsheet",
			"description": "On Ready calls a sample subsheet with one print action."
		}
	]


static func build(template_id: String) -> FKEventSheet:
	match template_id:
		"blank":
			return _blank()
		"on_ready_print":
			return _on_ready_print()
		"score_loop":
			return _score_loop()
		"or_example":
			return _or_example()
		"subsheet_call":
			return _subsheet_call()
		_:
			return _blank()


static func _blank() -> FKEventSheet:
	var sheet := FKEventSheet.new()
	sheet.sheet_var_defs = [{"name": "score", "type": "int", "default": 0}] as Array[Dictionary]
	return sheet


static func _event(event_id: String, target: String = "System") -> FKEventUnit:
	var e := FKEventUnit.new()
	e.event_id = event_id
	e.target_node = NodePath(target)
	e.enabled = true
	e.conditions = [] as Array[FKConditionUnit]
	e.actions = [] as Array[FKActionUnit]
	e.ensure_block_id()
	return e


static func _action(action_id: String, target: String, inputs: Dictionary = {}) -> FKActionUnit:
	var a := FKActionUnit.new()
	a.action_id = action_id
	a.target_node = NodePath(target)
	a.inputs = inputs.duplicate(true)
	a.enabled = true
	return a


static func _cond(condition_id: String, target: String, inputs: Dictionary = {}, or_prev: bool = false) -> FKConditionUnit:
	var c := FKConditionUnit.new()
	c.condition_id = condition_id
	c.target_node = NodePath(target)
	c.inputs = inputs.duplicate(true)
	c.or_with_previous = or_prev
	c.enabled = true
	return c


static func _append_event(sheet: FKEventSheet, e: FKEventUnit) -> void:
	sheet.events.append(e)
	sheet.item_order.append({"type": "event", "index": sheet.events.size() - 1})


static func _on_ready_print() -> FKEventSheet:
	var sheet := _blank()
	var e := _event("on_ready")
	e.actions.append(_action("print", "System", {"Message": "\"Hello from FlowKit template\""}))
	_append_event(sheet, e)
	return sheet


static func _score_loop() -> FKEventSheet:
	var sheet := FKEventSheet.new()
	sheet.sheet_var_defs = [{"name": "score", "type": "int", "default": 0}] as Array[Dictionary]
	var ready := _event("on_ready")
	ready.actions.append(_action("set_sheet_variable", "System", {"Name": "score", "Value": "0"}))
	ready.actions.append(_action("print", "System", {"Message": "\"score ready\""}))
	_append_event(sheet, ready)
	var key := _event("on_key_pressed")
	key.inputs = {"Key": "Space"}
	key.actions.append(_action("set_sheet_variable", "System", {
		"Name": "score",
		"Value": "s_score + 1"
	}))
	key.actions.append(_action("print", "System", {"Message": "\"score=\" + str(s_score)"}))
	_append_event(sheet, key)
	return sheet


static func _or_example() -> FKEventSheet:
	var sheet := _blank()
	var e := _event("on_process")
	# Example: compare with always-false style — use key conditions if available
	# Prefer system conditions that exist: keep simple print after empty OR group
	var c1 := _cond("compare_sheet_variable", "System", {
		"Name": "score",
		"Comparison": "==",
		"Value": 0
	}, false)
	var c2 := _cond("compare_sheet_variable", "System", {
		"Name": "score",
		"Comparison": ">",
		"Value": 0
	}, true)
	e.conditions.append(c1)
	e.conditions.append(c2)
	e.actions.append(_action("print", "System", {"Message": "\"OR group matched (score == 0 OR score > 0)\""}))
	e.trigger_once = true
	_append_event(sheet, e)
	return sheet


static func _subsheet_call() -> FKEventSheet:
	var sheet := _blank()
	var sub_script = load("res://addons/flowkit/resources/fk_subsheet.gd")
	var sub = sub_script.new()
	sub.subsheet_name = "hello_sub"
	sub.actions = [] as Array[FKActionUnit]
	sub.actions.append(_action("print", "System", {"Message": "\"Hello from subsheet\""}))
	sheet.subsheets = [sub]
	var e := _event("on_ready")
	e.actions.append(_action("call_subsheet", "System", {
		"Name": "hello_sub",
		"ArgsJson": "",
		"StoreAs": ""
	}))
	_append_event(sheet, e)
	return sheet
