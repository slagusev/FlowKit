extends FKAction

func get_description() -> String:
	return "Smoothly tweens a Node2D to a target position over Duration seconds."

func get_id() -> String:
	return "tween_position"

func get_name() -> String:
	return "Tween Position"

func get_supported_types() -> Array[String]:
	return ["Node2D"]

func requires_multi_frames() -> bool:
	return true

func get_inputs() -> Array[FKActionInput]:
	return [_x_input, _y_input, _duration_input]

static var _x_input: FKFloatActionInput:
	get:
		return FKFloatActionInput.new("X", "Target position X.")

static var _y_input: FKFloatActionInput:
	get:
		return FKFloatActionInput.new("Y", "Target position Y.")

static var _duration_input: FKFloatActionInput:
	get:
		return FKFloatActionInput.new("Duration", "Tween duration in seconds.", 0.3)

func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if not node is Node2D or not is_instance_valid(node):
		exec_completed.emit()
		return
	
	var target := Vector2(_x_input.get_val(inputs), _y_input.get_val(inputs))
	var duration: float = maxf(_duration_input.get_val(inputs), 0.0)
	
	if duration <= 0.0:
		(node as Node2D).global_position = target
		exec_completed.emit()
		return
	
	var tween := node.create_tween()
	tween.tween_property(node, "global_position", target, duration)
	await tween.finished
	exec_completed.emit()
