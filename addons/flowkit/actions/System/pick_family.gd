extends FKAction

func get_description() -> String:
	return "Runs Pick Nodes using a family defined by Define Family."

func get_id() -> String:
	return "pick_family"

func get_name() -> String:
	return "Pick Family"

func get_supported_types() -> Array[String]:
	return ["System"]

func get_inputs() -> Array[FKActionInput]:
	return [_name]

static var _name: FKStringActionInput:
	get: return FKStringActionInput.new("Name", "Family name.")

func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	var fname: String = str(_name.get_val(inputs)).strip_edges()
	var system = node.get_tree().root.get_node_or_null("/root/FlowKitSystem") if node and node.get_tree() else null
	if system == null or not ("families" in system) or not system.families.has(fname):
		push_warning("[FlowKit] Pick Family: unknown family '%s'" % fname)
		return
	var fam: Dictionary = system.families[fname]
	# Reuse pick_nodes logic by instantiating provider
	var pick = load("res://addons/flowkit/actions/System/pick_nodes.gd").new()
	var pick_inputs := {
		"Group": fam.get("group", ""),
		"Class": fam.get("class", ""),
		"Filter": fam.get("filter", ""),
		"RandomOne": false,
		"InvertFilter": false,
		"MaxCount": 0
	}
	pick.execute(node, pick_inputs, block_id)
