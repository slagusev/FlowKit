extends FKAction

func get_description() -> String:
	return "Rotates a Node3D around its Y axis by the given radians."

func get_id() -> String:
	return "rotate_y_3d"

func get_name() -> String:
	return "Rotate Y (3D)"

func get_supported_types() -> Array[String]:
	return ["Node3D"]

func get_inputs() -> Array[FKActionInput]:
	return [_angle]

static var _angle: FKFloatActionInput:
	get: return FKFloatActionInput.new("Radians", "Rotation amount in radians.")

func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node is Node3D:
		(node as Node3D).rotate_y(_angle.get_val(inputs))