extends FKAction
func get_description() -> String: return "Starts or stops GPUParticles2D emission."
func get_id() -> String: return "particles2d_set_emitting"
func get_name() -> String: return "Set Emitting"
func get_supported_types() -> Array[String]: return ["GPUParticles2D", "CPUParticles2D"]
func get_inputs() -> Array[FKActionInput]: return [_e]
static var _e: FKActionInput:
	get: return FKActionInput.new("Emitting", "bool", "", true)
func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if "emitting" in node: node.set("emitting", bool(_e.get_val(inputs)))
