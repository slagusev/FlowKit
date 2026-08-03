extends FKAction
func get_description() -> String: return "Sets collision_layer bitfield on CollisionObject2D."
func get_id() -> String: return "collision2d_set_layer"
func get_name() -> String: return "Set Collision Layer"
func get_supported_types() -> Array[String]: return ["CollisionObject2D"]
func get_inputs() -> Array[FKActionInput]: return [_l]
static var _l: FKIntActionInput:
	get: return FKIntActionInput.new("Layer", "Bitmask (e.g. 1, 2, 4...)", 1)
func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node is CollisionObject2D: (node as CollisionObject2D).collision_layer = _l.get_val(inputs)
