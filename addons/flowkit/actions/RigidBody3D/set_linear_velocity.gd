extends FKAction
func get_description() -> String: return "Sets linear velocity on RigidBody3D."
func get_id() -> String: return "rigidbody3d_set_linear_velocity"
func get_name() -> String: return "Set Linear Velocity (3D)"
func get_supported_types() -> Array[String]: return ["RigidBody3D"]
func get_inputs() -> Array[FKActionInput]: return [_x, _y, _z]
static var _x: FKFloatActionInput:
	get: return FKFloatActionInput.new("X", "")
static var _y: FKFloatActionInput:
	get: return FKFloatActionInput.new("Y", "")
static var _z: FKFloatActionInput:
	get: return FKFloatActionInput.new("Z", "")
func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node is RigidBody3D:
		(node as RigidBody3D).linear_velocity = Vector3(_x.get_val(inputs), _y.get_val(inputs), _z.get_val(inputs))
