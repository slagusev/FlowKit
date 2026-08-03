extends FKCondition
func get_description() -> String: return "True when CharacterBody2D is on ceiling."
func get_id() -> String: return "is_on_ceiling"
func get_name() -> String: return "Is on Ceiling"
func get_inputs() -> Array[Dictionary]: return []
func get_supported_types() -> Array[String]: return ["CharacterBody2D"]
func check(node: Node, inputs: Dictionary, block_id: String = "") -> bool:
	return node is CharacterBody2D and (node as CharacterBody2D).is_on_ceiling()
