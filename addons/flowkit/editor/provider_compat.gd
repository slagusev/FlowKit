extends RefCounted
class_name FKProviderCompat
## Shared helpers for provider/node type matching and registry-backed provider lists.

## True if node_class matches any entry in supported_types (exact, "Node", or inheritance).
static func is_node_compatible(node_class: String, supported_types: Array) -> bool:
	if node_class.is_empty() or supported_types.is_empty():
		return false
	# System pseudo-node
	if node_class == "System":
		for t in supported_types:
			if str(t) == "System" or str(t) == "Node":
				return true
		return false
	for supported_type in supported_types:
		var st := str(supported_type)
		if st.is_empty():
			continue
		# Exact match
		if st == node_class:
			return true
		# Convention: "Node" accepts every real scene node class.
		if st == "Node":
			return true
		# Inheritance either direction (Sprite2D ↔ Node2D / CanvasItem).
		if ClassDB.class_exists(node_class) and ClassDB.class_exists(st):
			if ClassDB.is_parent_class(node_class, st):
				return true
			if ClassDB.is_parent_class(st, node_class):
				return true
	return false


## Live registry provider list for kind (action/condition/event/behavior/branch).
static func providers_from_registry(registry: Variant, kind: String) -> Array:
	if registry == null:
		return []
	# Direct fields — avoid Object.get() which can miss script vars in editor contexts.
	match kind:
		"action":
			return registry.action_providers
		"condition":
			return registry.condition_providers
		"event":
			return registry.event_providers
		"behavior":
			return registry.behavior_providers
		"branch":
			return registry.branch_providers
		_:
			return []
