extends FKAction
func get_description() -> String: return "Stops AudioStreamPlayer."
func get_id() -> String: return "audio_stop"
func get_name() -> String: return "Stop"
func get_supported_types() -> Array[String]: return ["AudioStreamPlayer"]
func get_inputs() -> Array[FKActionInput]: return []
func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node is AudioStreamPlayer: (node as AudioStreamPlayer).stop()
