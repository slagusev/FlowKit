extends FKCondition
func get_description() -> String: return "True when AnimationPlayer is playing."
func get_id() -> String: return "animation_player_is_playing"
func get_name() -> String: return "Is Playing"
func get_inputs() -> Array[Dictionary]: return []
func get_supported_types() -> Array[String]: return ["AnimationPlayer"]
func check(node: Node, inputs: Dictionary, block_id: String = "") -> bool:
	return node is AnimationPlayer and (node as AnimationPlayer).is_playing()
