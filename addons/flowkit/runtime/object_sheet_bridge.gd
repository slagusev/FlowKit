extends RefCounted
class_name FKObjectSheetBridge
## Object Mode ↔ Event Sheet helpers (v3.12).
## Promote local rules into scene sheet events (On Object Event listeners).


## Build a sheet event unit dict for listening to an object event name.
static func make_object_event_listener(event_name: String, action_print: bool = true) -> Dictionary:
	var en := event_name.strip_edges()
	if en.is_empty():
		en = "object"
	var actions: Array = []
	if action_print:
		actions.append({
			"action_id": "print",
			"target_node": "System",
			"inputs": {"Message": "\"[ObjectEvent] %s\"" % en},
			"enabled": true
		})
	return {
		"event_id": "on_object_event",
		"target_node": "System",
		"inputs": {"Event": en, "SourceGroup": ""},
		"conditions": [],
		"actions": actions,
		"enabled": true,
		"trigger_once": false,
		"block_id": "obj_" + en + "_" + str(Time.get_ticks_msec())
	}


## Convert a local rule into an emit_object_event rule + return listener event dict.
## Mutates node rules if ensure_emit is true.
static func promote_rule(
	node: Node,
	rule: Dictionary,
	ensure_emit: bool = true
) -> Dictionary:
	if node == null or rule.is_empty():
		return {}
	var then_id := str(rule.get("then", ""))
	var event_name := "object"
	var params: Dictionary = rule.get("params", {}) if rule.get("params", {}) is Dictionary else {}
	if then_id == "emit_object_event":
		event_name = str(params.get("Event", params.get("Name", "object")))
	elif then_id == "queue_free" or then_id == "hide":
		event_name = str(rule.get("id", "object_rule"))
		if event_name.is_empty():
			event_name = "object_rule"
	else:
		event_name = str(rule.get("id", then_id))
		if event_name.is_empty():
			event_name = "promoted"

	if ensure_emit and then_id != "emit_object_event":
		# Append companion emit rule with same when (once)
		var rules: Array = FKObjectConfig.get_local_rules(node)
		var emit_id := "promote_emit_" + event_name
		var exists := false
		for r in rules:
			if r is Dictionary and str(r.get("id", "")) == emit_id:
				exists = true
				break
		if not exists:
			rules.append({
				"id": emit_id,
				"enabled": true,
				"when": str(rule.get("when", "always")),
				"then": "emit_object_event",
				"params": {"Event": event_name},
				"once": bool(rule.get("once", true))
			})
			FKObjectConfig.set_local_rules(node, rules)

	return make_object_event_listener(event_name, true)


## Append listener event to the scene's FlowKit sheet (load/save via FKSheetIO).
static func append_listener_to_scene_sheet(
	scene_root: Node,
	listener_event: Dictionary
) -> bool:
	if scene_root == null or listener_event.is_empty():
		return false
	var uid := 0
	if scene_root.scene_file_path != "":
		uid = hash(scene_root.scene_file_path)
	# Prefer ResourceUID if available
	if scene_root.scene_file_path != "" and ResourceLoader.exists(scene_root.scene_file_path):
		var id := ResourceLoader.get_resource_uid(scene_root.scene_file_path)
		if id != ResourceUID.INVALID_ID:
			uid = id
	var scene_name := scene_root.scene_file_path.get_file().get_basename()
	if scene_name.is_empty():
		scene_name = scene_root.name
	var io := FKSheetIO.new()
	var sheet: FKEventSheet = io.load_sheet(uid, scene_name)
	if sheet == null:
		sheet = io.new_sheet()
	# Build real unit
	var ev := FKEventUnit.new()
	ev.event_id = str(listener_event.get("event_id", "on_object_event"))
	ev.target_node = NodePath(str(listener_event.get("target_node", "System")))
	ev.inputs = listener_event.get("inputs", {}) if listener_event.get("inputs", {}) is Dictionary else {}
	ev.enabled = true
	ev.ensure_block_id()
	if listener_event.has("block_id"):
		ev.block_id = str(listener_event.get("block_id"))
	var acts: Array = listener_event.get("actions", [])
	for a in acts:
		if not (a is Dictionary):
			continue
		var au := FKActionUnit.new()
		au.action_id = str(a.get("action_id", "print"))
		au.target_node = NodePath(str(a.get("target_node", "System")))
		au.inputs = a.get("inputs", {}) if a.get("inputs", {}) is Dictionary else {}
		au.enabled = true
		ev.actions.append(au)
	sheet.events.append(ev)
	sheet.item_order.append({"type": "event", "index": sheet.events.size() - 1})
	var err := io.save_sheet(uid, sheet, scene_name)
	return err == OK
