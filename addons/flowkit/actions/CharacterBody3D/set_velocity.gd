extends FKAction

func get_description() -> String:
	return "Sets the full velocity vector of a CharacterBody3D."

func get_id() -> String:
	return "set_velocity_3d"

func get_name() -> String:
	return "Set Velocity (3D)"

func get_supported_types() -> Array[String]:
	return ["CharacterBody3D"]

func get_inputs() -> Array[FKActionInput]:
	return [_x, _y, _z]

static var _x: FKFloatActionInput:
	get: return FKFloatActionInput.new("X", "Velocity X")
static var _y: FKFloatActionInput:
	get: return FKFloatActionInput.new("Y", "Velocity Y")
static var _z: FKFloatActionInput:
	get: return FKFloatActionInput.new("Z", "Velocity Z")

func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node is CharacterBody3D:
		(node as CharacterBody3D).velocity = Vector3(_x.get_val(inputs), _y.get_val(inputs), _z.get_val(inputs))