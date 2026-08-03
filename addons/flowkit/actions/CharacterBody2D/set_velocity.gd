extends FKAction
func get_description() -> String: return "Sets full velocity Vector2 on CharacterBody2D."
func get_id() -> String: return "set_velocity_2d"
func get_name() -> String: return "Set Velocity"
func get_supported_types() -> Array[String]: return ["CharacterBody2D"]
func get_inputs() -> Array[FKActionInput]: return [_x, _y]
static var _x: FKFloatActionInput:
	get: return FKFloatActionInput.new("X", "Velocity X")
static var _y: FKFloatActionInput:
	get: return FKFloatActionInput.new("Y", "Velocity Y")
func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node is CharacterBody2D:
		(node as CharacterBody2D).velocity = Vector2(_x.get_val(inputs), _y.get_val(inputs))
