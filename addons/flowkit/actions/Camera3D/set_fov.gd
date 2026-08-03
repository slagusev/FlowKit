extends FKAction
func get_description() -> String: return "Sets Camera3D field of view."
func get_id() -> String: return "camera3d_set_fov"
func get_name() -> String: return "Set FOV"
func get_supported_types() -> Array[String]: return ["Camera3D"]
func get_inputs() -> Array[FKActionInput]: return [_f]
static var _f: FKFloatActionInput:
	get: return FKFloatActionInput.new("FOV", "Degrees", 75.0)
func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node is Camera3D: (node as Camera3D).fov = _f.get_val(inputs)
