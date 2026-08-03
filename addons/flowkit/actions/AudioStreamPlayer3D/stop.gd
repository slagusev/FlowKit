extends FKAction
func get_description() -> String: return "Stops AudioStreamPlayer3D."
func get_id() -> String: return "audio3d_stop"
func get_name() -> String: return "Stop (3D Audio)"
func get_supported_types() -> Array[String]: return ["AudioStreamPlayer3D"]
func get_inputs() -> Array[FKActionInput]: return []
func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node is AudioStreamPlayer3D: (node as AudioStreamPlayer3D).stop()
