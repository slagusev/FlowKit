extends FKAction
func get_description() -> String: return "Sets linear velocity on RigidBody2D."
func get_id() -> String: return "rigidbody2d_set_linear_velocity"
func get_name() -> String: return "Set Linear Velocity"
func get_supported_types() -> Array[String]: return ["RigidBody2D"]
func get_inputs() -> Array[FKActionInput]: return [_x, _y]
static var _x: FKFloatActionInput:
	get: return FKFloatActionInput.new("X", "Velocity X")
static var _y: FKFloatActionInput:
	get: return FKFloatActionInput.new("Y", "Velocity Y")
func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node is RigidBody2D:
		(node as RigidBody2D).linear_velocity = Vector2(_x.get_val(inputs), _y.get_val(inputs))
