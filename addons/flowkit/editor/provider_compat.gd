extends RefCounted
class_name FKProviderCompat
## Shared helpers for provider/node type matching and registry-backed provider lists.

## True if node_class matches any entry in supported_types (exact, "Node", or inheritance).
static func is_node_compatible(node_class: String, supported_types: Array) -> bool:
	if supported_types.is_empty():
		return false
	if node_class in supported_types:
		return true
	# "Node" matches all node classes (legacy provider convention).
	if "Node" in supported_types:
		return true
	for supported_type in supported_types:
		if typeof(supported_type) != TYPE_STRING:
			continue
		var st: String = supported_type
		if st.is_empty() or st == "System":
			continue
		if ClassDB.class_exists(node_class) and ClassDB.class_exists(st):
			if ClassDB.is_parent_class(node_class, st):
				return true
	return false


## Prefer live registry list; if empty and in editor, return empty (caller may fall back).
static func providers_from_registry(registry: Variant, kind: String) -> Array:
	if registry == null:
		return []
	# Prefer direct property access — `"prop" in object` is unreliable on some Node types.
	match kind:
		"action":
			return registry.action_providers if registry.get("action_providers") != null else []
		"condition":
			return registry.condition_providers if registry.get("condition_providers") != null else []
		"event":
			return registry.event_providers if registry.get("event_providers") != null else []
		"behavior":
			return registry.behavior_providers if registry.get("behavior_providers") != null else []
		"branch":
			return registry.branch_providers if registry.get("branch_providers") != null else []
		_:
			return []
