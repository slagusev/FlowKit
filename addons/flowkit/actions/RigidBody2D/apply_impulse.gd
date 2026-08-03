extends FKAction
func get_description() -> String: return "Applies a central impulse to RigidBody2D."
func get_id() -> String: return "rigidbody2d_apply_impulse"
func get_name() -> String: return "Apply Impulse"
func get_supported_types() -> Array[String]: return ["RigidBody2D"]
func get_inputs() -> Array[FKActionInput]: return [_x, _y]
static var _x: FKFloatActionInput:
	get: return FKFloatActionInput.new("X", "Impulse X")
static var _y: FKFloatActionInput:
	get: return FKFloatActionInput.new("Y", "Impulse Y")
func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node is RigidBody2D:
		(node as RigidBody2D).apply_central_impulse(Vector2(_x.get_val(inputs), _y.get_val(inputs)))
