extends FKAction
func get_description() -> String: return "Enables or disables Light3D."
func get_id() -> String: return "light3d_set_enabled"
func get_name() -> String: return "Set Enabled (3D Light)"
func get_supported_types() -> Array[String]: return ["Light3D"]
func get_inputs() -> Array[FKActionInput]: return [_e]
static var _e: FKActionInput:
	get: return FKActionInput.new("Enabled", "bool", "", true)
func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node is Light3D: (node as Light3D).visible = bool(_e.get_val(inputs))
