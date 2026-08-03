extends FKAction
func get_description() -> String: return "Starts or stops GPUParticles3D emission."
func get_id() -> String: return "particles3d_set_emitting"
func get_name() -> String: return "Set Emitting (3D)"
func get_supported_types() -> Array[String]: return ["GPUParticles3D", "CPUParticles3D"]
func get_inputs() -> Array[FKActionInput]: return [_e]
static var _e: FKActionInput:
	get: return FKActionInput.new("Emitting", "bool", "", true)
func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if "emitting" in node: node.set("emitting", bool(_e.get_val(inputs)))
