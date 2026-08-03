extends FKAction
func get_description() -> String: return "Sets rotation_degrees of a Node3D."
func get_id() -> String: return "node3d_set_rotation_degrees"
func get_name() -> String: return "Set Rotation Degrees (3D)"
func get_supported_types() -> Array[String]: return ["Node3D"]
func get_inputs() -> Array[FKActionInput]: return [_x, _y, _z]
static var _x: FKFloatActionInput:
	get: return FKFloatActionInput.new("X", "Pitch")
static var _y: FKFloatActionInput:
	get: return FKFloatActionInput.new("Y", "Yaw")
static var _z: FKFloatActionInput:
	get: return FKFloatActionInput.new("Z", "Roll")
func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node is Node3D: (node as Node3D).rotation_degrees = Vector3(_x.get_val(inputs), _y.get_val(inputs), _z.get_val(inputs))
