extends FKAction

func get_description() -> String:
	return "Rotates a Node2D to look toward a world-space position."

func get_id() -> String:
	return "look_at_position"

func get_name() -> String:
	return "Look At Position"

func get_supported_types() -> Array[String]:
	return ["Node2D"]

func get_inputs() -> Array[FKActionInput]:
	return [_x_input, _y_input]

static var _x_input: FKFloatActionInput:
	get:
		return FKFloatActionInput.new("X", "Target world X.")

static var _y_input: FKFloatActionInput:
	get:
		return FKFloatActionInput.new("Y", "Target world Y.")

func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if not node is Node2D:
		return
	var x: float = _x_input.get_val(inputs)
	var y: float = _y_input.get_val(inputs)
	(node as Node2D).look_at(Vector2(x, y))
