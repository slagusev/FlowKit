extends FKCondition
func get_description() -> String: return "True when Sprite2D is flipped horizontally."
func get_id() -> String: return "sprite2d_is_flip_h"
func get_name() -> String: return "Is Flip H"
func get_inputs() -> Array[Dictionary]: return []
func get_supported_types() -> Array[String]: return ["Sprite2D"]
func check(node: Node, inputs: Dictionary, block_id: String = "") -> bool:
	return node is Sprite2D and (node as Sprite2D).flip_h
