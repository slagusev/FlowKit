extends FKAction
func get_description() -> String: return "Freezes or unfreezes RigidBody3D."
func get_id() -> String: return "rigidbody3d_set_freeze"
func get_name() -> String: return "Set Freeze (3D)"
func get_supported_types() -> Array[String]: return ["RigidBody3D"]
func get_inputs() -> Array[FKActionInput]: return [_f]
static var _f: FKActionInput:
	get: return FKActionInput.new("Freeze", "bool", "", true)
func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node is RigidBody3D: (node as RigidBody3D).freeze = bool(_f.get_val(inputs))
