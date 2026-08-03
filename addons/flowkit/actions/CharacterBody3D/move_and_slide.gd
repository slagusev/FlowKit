extends FKAction

func get_description() -> String:
	return "Moves the CharacterBody3D with sliding collision response."

func get_id() -> String:
	return "move_and_slide_3d"

func get_name() -> String:
	return "Move and Slide (3D)"

func get_supported_types() -> Array[String]:
	return ["CharacterBody3D"]

func get_inputs() -> Array[FKActionInput]:
	return []

func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node is CharacterBody3D:
		(node as CharacterBody3D).move_and_slide()