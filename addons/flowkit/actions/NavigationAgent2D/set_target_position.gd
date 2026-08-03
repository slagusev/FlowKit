extends FKAction

func get_description() -> String:
	return "Sets NavigationAgent2D target_position (world space)."

func get_id() -> String:
	return "nav2d_set_target_position"

func get_name() -> String:
	return "Set Target Position (Nav2D)"

func get_supported_types() -> Array[String]:
	return ["NavigationAgent2D"]

func get_inputs() -> Array[FKActionInput]:
	return [_x, _y]

static var _x: FKFloatActionInput:
	get: return FKFloatActionInput.new("X", "Target X", 0.0)
static var _y: FKFloatActionInput:
	get: return FKFloatActionInput.new("Y", "Target Y", 0.0)

func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node is NavigationAgent2D:
		(node as NavigationAgent2D).target_position = Vector2(float(_x.get_val(inputs)), float(_y.get_val(inputs)))
