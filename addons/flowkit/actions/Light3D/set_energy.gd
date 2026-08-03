extends FKAction
func get_description() -> String: return "Sets Light3D light energy."
func get_id() -> String: return "light3d_set_energy"
func get_name() -> String: return "Set Energy (3D)"
func get_supported_types() -> Array[String]: return ["Light3D"]
func get_inputs() -> Array[FKActionInput]: return [_e]
static var _e: FKFloatActionInput:
	get: return FKFloatActionInput.new("Energy", "", 1.0)
func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node is Light3D: (node as Light3D).light_energy = _e.get_val(inputs)
