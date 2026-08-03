extends FKCondition
func get_description() -> String: return "True when AnimatedSprite2D is playing."
func get_id() -> String: return "animatedsprite2d_is_playing"
func get_name() -> String: return "Is Playing"
func get_inputs() -> Array[Dictionary]: return []
func get_supported_types() -> Array[String]: return ["AnimatedSprite2D"]
func check(node: Node, inputs: Dictionary, block_id: String = "") -> bool:
	return node is AnimatedSprite2D and (node as AnimatedSprite2D).is_playing()
