extends FKAction

func get_description() -> String:
	return "Sets a shader parameter on the node's material (ShaderMaterial)."

func get_id() -> String:
	return "set_shader_param"

func get_name() -> String:
	return "Set Shader Param"

func get_supported_types() -> Array[String]:
	return ["CanvasItem", "GeometryInstance3D"]

func get_inputs() -> Array[FKActionInput]:
	return [_param, _value]

static var _param: FKStringActionInput:
	get: return FKStringActionInput.new("Param", "Shader parameter name.")

static var _value: FKActionInput:
	get: return FKActionInput.new("Value", "Variant", "Value to set.", 0.0)

func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	var pname: String = str(_param.get_val(inputs)).strip_edges()
	if pname.is_empty():
		return
	var mat: Material = null
	if node is CanvasItem:
		mat = (node as CanvasItem).material
	elif node is GeometryInstance3D:
		mat = (node as GeometryInstance3D).material_override
	if mat is ShaderMaterial:
		(mat as ShaderMaterial).set_shader_parameter(pname, _value.get_val(inputs))
