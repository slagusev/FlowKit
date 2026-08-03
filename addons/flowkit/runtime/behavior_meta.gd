extends RefCounted
class_name FKBehaviorMeta
## Read/write multi-behavior node metadata with legacy single-slot compatibility.
##
## Canonical: meta "flowkit_behaviors" = Array[{ "id": String, "inputs": Dictionary }]
## Legacy:    meta "flowkit_behavior"  = { "id": String, "inputs": Dictionary }

const META_MULTI := "flowkit_behaviors"
const META_LEGACY := "flowkit_behavior"


## Returns array of {id, inputs} for the node (never null).
static func get_behaviors(node: Node) -> Array:
	if node == null:
		return []
	if node.has_meta(META_MULTI):
		var raw = node.get_meta(META_MULTI)
		if raw is Array:
			return _sanitize_list(raw)
	if node.has_meta(META_LEGACY):
		var one = node.get_meta(META_LEGACY, {})
		if one is Dictionary and not str(one.get("id", "")).is_empty():
			return [{
				"id": str(one.get("id", "")),
				"inputs": (one.get("inputs", {}) as Dictionary).duplicate(true) if one.get("inputs", {}) is Dictionary else {}
			}]
	return []


static func _sanitize_list(raw: Array) -> Array:
	var out: Array = []
	for item in raw:
		if item is Dictionary:
			var bid := str(item.get("id", "")).strip_edges()
			if bid.is_empty():
				continue
			var inputs: Dictionary = {}
			if item.get("inputs", {}) is Dictionary:
				inputs = (item.get("inputs") as Dictionary).duplicate(true)
			out.append({"id": bid, "inputs": inputs})
	return out


## Replace full behavior list. Also mirrors first entry to legacy key for older tools/demos.
static func set_behaviors(node: Node, behaviors: Array) -> void:
	if node == null:
		return
	var clean := _sanitize_list(behaviors)
	if clean.is_empty():
		if node.has_meta(META_MULTI):
			node.remove_meta(META_MULTI)
		if node.has_meta(META_LEGACY):
			node.remove_meta(META_LEGACY)
		return
	node.set_meta(META_MULTI, clean)
	# Legacy mirror: first behavior only
	node.set_meta(META_LEGACY, {
		"id": clean[0]["id"],
		"inputs": clean[0]["inputs"]
	})


static func has_any(node: Node) -> bool:
	return not get_behaviors(node).is_empty()


static func add_or_replace(node: Node, behavior_id: String, inputs: Dictionary = {}) -> void:
	var bid := behavior_id.strip_edges()
	if node == null or bid.is_empty():
		return
	var list := get_behaviors(node)
	var found := false
	for i in range(list.size()):
		if str(list[i].get("id", "")) == bid:
			list[i] = {"id": bid, "inputs": inputs.duplicate(true)}
			found = true
			break
	if not found:
		list.append({"id": bid, "inputs": inputs.duplicate(true)})
	set_behaviors(node, list)


static func remove_id(node: Node, behavior_id: String) -> void:
	var bid := behavior_id.strip_edges()
	if node == null or bid.is_empty():
		return
	var list := get_behaviors(node)
	var next: Array = []
	for item in list:
		if str(item.get("id", "")) != bid:
			next.append(item)
	set_behaviors(node, next)


static func clear_all(node: Node) -> void:
	set_behaviors(node, [])
