extends FKCondition
func get_description() -> String: return "True when RayCast2D is colliding."
func get_id() -> String: return "raycast2d_is_colliding"
func get_name() -> String: return "Is Colliding"
func get_inputs() -> Array[Dictionary]: return []
func get_supported_types() -> Array[String]: return ["RayCast2D"]
func check(node: Node, inputs: Dictionary, block_id: String = "") -> bool:
	return node is RayCast2D and (node as RayCast2D).is_colliding()
