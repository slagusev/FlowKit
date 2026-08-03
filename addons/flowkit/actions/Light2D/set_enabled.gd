extends FKAction
func get_description() -> String: return "Enables or disables Light2D."
func get_id() -> String: return "light2d_set_enabled"
func get_name() -> String: return "Set Enabled"
func get_supported_types() -> Array[String]: return ["Light2D"]
func get_inputs() -> Array[FKActionInput]: return [_e]
static var _e: FKActionInput:
	get: return FKActionInput.new("Enabled", "bool", "", true)
func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node is Light2D: (node as Light2D).enabled = bool(_e.get_val(inputs))
