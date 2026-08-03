extends FKAction
func get_description() -> String: return "Enables or disables a CollisionShape2D."
func get_id() -> String: return "collisionshape2d_set_disabled"
func get_name() -> String: return "Set Disabled"
func get_supported_types() -> Array[String]: return ["CollisionShape2D"]
func get_inputs() -> Array[FKActionInput]: return [_d]
static var _d: FKActionInput:
	get: return FKActionInput.new("Disabled", "bool", "", true)
func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node is CollisionShape2D: (node as CollisionShape2D).disabled = bool(_d.get_val(inputs))
