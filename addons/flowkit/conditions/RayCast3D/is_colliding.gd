extends FKCondition
func get_description() -> String: return "True when RayCast3D is colliding."
func get_id() -> String: return "raycast3d_is_colliding"
func get_name() -> String: return "Is Colliding (3D)"
func get_inputs() -> Array[Dictionary]: return []
func get_supported_types() -> Array[String]: return ["RayCast3D"]
func check(node: Node, inputs: Dictionary, block_id: String = "") -> bool:
	return node is RayCast3D and (node as RayCast3D).is_colliding()
