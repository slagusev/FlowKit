extends FKAction
func get_description() -> String: return "Sets collision_layer on CollisionObject3D."
func get_id() -> String: return "collision3d_set_layer"
func get_name() -> String: return "Set Collision Layer (3D)"
func get_supported_types() -> Array[String]: return ["CollisionObject3D"]
func get_inputs() -> Array[FKActionInput]: return [_l]
static var _l: FKIntActionInput:
	get: return FKIntActionInput.new("Layer", "Bitmask", 1)
func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node is CollisionObject3D: (node as CollisionObject3D).collision_layer = _l.get_val(inputs)
