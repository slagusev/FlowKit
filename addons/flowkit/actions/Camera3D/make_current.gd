extends FKAction

func get_description() -> String:
	return "Makes this Camera3D the active camera."

func get_id() -> String:
	return "camera3d_make_current"

func get_name() -> String:
	return "Make Current"

func get_supported_types() -> Array[String]:
	return ["Camera3D"]

func get_inputs() -> Array[FKActionInput]:
	return []

func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node is Camera3D:
		(node as Camera3D).make_current()