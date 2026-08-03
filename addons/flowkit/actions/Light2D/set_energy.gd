extends FKAction
func get_description() -> String: return "Sets Light2D energy."
func get_id() -> String: return "light2d_set_energy"
func get_name() -> String: return "Set Energy"
func get_supported_types() -> Array[String]: return ["Light2D"]
func get_inputs() -> Array[FKActionInput]: return [_e]
static var _e: FKFloatActionInput:
	get: return FKFloatActionInput.new("Energy", "Light energy", 1.0)
func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node is Light2D: (node as Light2D).energy = _e.get_val(inputs)
