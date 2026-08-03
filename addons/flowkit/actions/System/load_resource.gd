extends FKAction

func get_description() -> String:
	return "Loads a resource path into system variable (system.set_var)."

func get_id() -> String:
	return "load_resource"

func get_name() -> String:
	return "Load Resource"

func get_supported_types() -> Array[String]:
	return ["System"]

func get_inputs() -> Array[FKActionInput]:
	return [_path, _var]

static var _path: FKStringActionInput:
	get: return FKStringActionInput.new("Path", "res:// path to resource.")

static var _var: FKStringActionInput:
	get: return FKStringActionInput.new("VarName", "System variable name to store Resource.")

func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	var path: String = str(_path.get_val(inputs)).strip_edges()
	var vname: String = str(_var.get_val(inputs)).strip_edges()
	if path.is_empty() or vname.is_empty():
		return
	if not ResourceLoader.exists(path):
		push_warning("[FlowKit] Load Resource: missing " + path)
		return
	var res = load(path)
	var system = node.get_tree().root.get_node_or_null("/root/FlowKitSystem") if node and node.get_tree() else null
	if system and system.has_method("set_var"):
		system.set_var(vname, res)
