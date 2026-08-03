extends FKAction
func get_description() -> String: return "Enables or disables CollisionShape3D."
func get_id() -> String: return "collisionshape3d_set_disabled"
func get_name() -> String: return "Set Disabled (3D Shape)"
func get_supported_types() -> Array[String]: return ["CollisionShape3D"]
func get_inputs() -> Array[FKActionInput]: return [_d]
static var _d: FKActionInput:
	get: return FKActionInput.new("Disabled", "bool", "", true)
func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node is CollisionShape3D: (node as CollisionShape3D).disabled = bool(_d.get_val(inputs))
