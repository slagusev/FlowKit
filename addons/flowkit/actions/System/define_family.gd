extends FKAction

func get_description() -> String:
	return "Defines a named family (saved pick query) on system.families."

func get_id() -> String:
	return "define_family"

func get_name() -> String:
	return "Define Family"

func get_supported_types() -> Array[String]:
	return ["System"]

func get_inputs() -> Array[FKActionInput]:
	return [_name, _group, _class, _filter]

static var _name: FKStringActionInput:
	get: return FKStringActionInput.new("Name", "Family name, e.g. weak_enemies.")
static var _group: FKStringActionInput:
	get: return FKStringActionInput.new("Group", "Group filter.")
static var _class: FKStringActionInput:
	get: return FKStringActionInput.new("Class", "Class filter.")
static var _filter: FKStringActionInput:
	get: return FKStringActionInput.new("Filter", "Optional Expression with n.")

func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	var fname: String = str(_name.get_val(inputs)).strip_edges()
	if fname.is_empty():
		return
	var system = node.get_tree().root.get_node_or_null("/root/FlowKitSystem") if node and node.get_tree() else null
	if system and "families" in system:
		system.families[fname] = {
			"group": str(_group.get_val(inputs)),
			"class": str(_class.get_val(inputs)),
			"filter": str(_filter.get_val(inputs))
		}
