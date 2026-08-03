extends FKAction

func get_description() -> String:
	return "Rotates a Node3D to look at a world-space point."

func get_id() -> String:
	return "look_at_3d"

func get_name() -> String:
	return "Look At (3D)"

func get_supported_types() -> Array[String]:
	return ["Node3D"]

func get_inputs() -> Array[FKActionInput]:
	return [_x, _y, _z]

static var _x: FKFloatActionInput:
	get: return FKFloatActionInput.new("X", "Target X")
static var _y: FKFloatActionInput:
	get: return FKFloatActionInput.new("Y", "Target Y")
static var _z: FKFloatActionInput:
	get: return FKFloatActionInput.new("Z", "Target Z")

func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node is Node3D:
		(node as Node3D).look_at(Vector3(_x.get_val(inputs), _y.get_val(inputs), _z.get_val(inputs)))