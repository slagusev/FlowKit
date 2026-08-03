extends FKCondition

func get_description() -> String:
	return "True when the CharacterBody2D is colliding with a ceiling."

func get_id() -> String:
	return "is_on_ceiling"

func get_name() -> String:
	return "Is on Ceiling"

func get_inputs() -> Array[Dictionary]:
	return []

func get_supported_types() -> Array[String]:
	return ["CharacterBody2D"]

func check(node: Node, inputs: Dictionary, block_id: String = "") -> bool:
	if not node is CharacterBody2D:
		return false
	return (node as CharacterBody2D).is_on_ceiling()
