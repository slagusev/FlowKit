extends FKAction
func get_description() -> String: return "Plays AudioStreamPlayer (non-2D)."
func get_id() -> String: return "audio_play"
func get_name() -> String: return "Play"
func get_supported_types() -> Array[String]: return ["AudioStreamPlayer"]
func get_inputs() -> Array[FKActionInput]: return []
func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node is AudioStreamPlayer: (node as AudioStreamPlayer).play()
