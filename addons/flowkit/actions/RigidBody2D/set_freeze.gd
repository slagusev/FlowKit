extends FKAction
func get_description() -> String: return "Freezes or unfreezes a RigidBody2D."
func get_id() -> String: return "rigidbody2d_set_freeze"
func get_name() -> String: return "Set Freeze"
func get_supported_types() -> Array[String]: return ["RigidBody2D"]
func get_inputs() -> Array[FKActionInput]: return [_f]
static var _f: FKActionInput:
	get: return FKActionInput.new("Freeze", "bool", "", true)
func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node is RigidBody2D: (node as RigidBody2D).freeze = bool(_f.get_val(inputs))
