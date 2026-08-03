extends FKAction
func get_description() -> String: return "Stops AnimationPlayer."
func get_id() -> String: return "animation_player_stop"
func get_name() -> String: return "Stop Animation"
func get_supported_types() -> Array[String]: return ["AnimationPlayer"]
func get_inputs() -> Array[FKActionInput]: return []
func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node is AnimationPlayer: (node as AnimationPlayer).stop()
