extends FKAction
func get_description() -> String: return "Sets collision_mask on CollisionObject3D."
func get_id() -> String: return "collision3d_set_mask"
func get_name() -> String: return "Set Collision Mask (3D)"
func get_supported_types() -> Array[String]: return ["CollisionObject3D"]
func get_inputs() -> Array[FKActionInput]: return [_m]
static var _m: FKIntActionInput:
	get: return FKIntActionInput.new("Mask", "Bitmask", 1)
func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node is CollisionObject3D: (node as CollisionObject3D).collision_mask = _m.get_val(inputs)
