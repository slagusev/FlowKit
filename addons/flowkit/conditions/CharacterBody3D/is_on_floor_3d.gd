extends FKCondition

func get_description() -> String:
	return "True when the CharacterBody3D is on the floor."

func get_id() -> String:
	return "is_on_floor_3d"

func get_name() -> String:
	return "Is on Floor (3D)"

func get_inputs() -> Array[Dictionary]:
	return []

func get_supported_types() -> Array[String]:
	return ["CharacterBody3D"]

func check(node: Node, inputs: Dictionary, block_id: String = "") -> bool:
	return node is CharacterBody3D and (node as CharacterBody3D).is_on_floor()