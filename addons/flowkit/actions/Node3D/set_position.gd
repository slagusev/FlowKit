extends FKAction

func get_description() -> String:
	return "Sets the global position of a Node3D."

func get_id() -> String:
	return "set_position_3d"

func get_name() -> String:
	return "Set Position (3D)"

func get_supported_types() -> Array[String]:
	return ["Node3D"]

func get_inputs() -> Array[FKActionInput]:
	return [_x, _y, _z]

static var _x: FKFloatActionInput:
	get: return FKFloatActionInput.new("X", "World X")
static var _y: FKFloatActionInput:
	get: return FKFloatActionInput.new("Y", "World Y")
static var _z: FKFloatActionInput:
	get: return FKFloatActionInput.new("Z", "World Z")

func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node is Node3D:
		(node as Node3D).global_position = Vector3(_x.get_val(inputs), _y.get_val(inputs), _z.get_val(inputs))