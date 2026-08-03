extends FKAction
func get_description() -> String: return "Stops AnimatedSprite2D animation."
func get_id() -> String: return "animatedsprite2d_stop"
func get_name() -> String: return "Stop"
func get_supported_types() -> Array[String]: return ["AnimatedSprite2D"]
func get_inputs() -> Array[FKActionInput]: return []
func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node is AnimatedSprite2D: (node as AnimatedSprite2D).stop()
