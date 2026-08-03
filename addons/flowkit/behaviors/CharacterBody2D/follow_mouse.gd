extends FKBehavior

func get_description() -> String:
	return "Moves CharacterBody2D toward the mouse position at a given speed."

func get_id() -> String:
	return "follow_mouse"

func get_name() -> String:
	return "Follow Mouse"

func get_inputs() -> Array[Dictionary]:
	return [
		{"name": "speed", "type": "float", "default": 250.0},
		{"name": "stop_distance", "type": "float", "default": 4.0},
	]

func get_supported_types() -> Array[String]:
	return ["CharacterBody2D"]

func apply(node: Node, inputs: Dictionary) -> void:
	node.set_meta("flowkit_behavior_" + get_id(), inputs)

func remove(node: Node) -> void:
	var k := "flowkit_behavior_" + get_id()
	if node.has_meta(k):
		node.remove_meta(k)

func physics_process(node: Node, delta: float, inputs: Dictionary) -> void:
	if not node is CharacterBody2D:
		return
	var body := node as CharacterBody2D
	var target: Vector2 = body.get_global_mouse_position()
	var to := target - body.global_position
	var stop_d: float = float(inputs.get("stop_distance", 4.0))
	var speed: float = float(inputs.get("speed", 250.0))
	if to.length() <= stop_d:
		body.velocity = Vector2.ZERO
	else:
		body.velocity = to.normalized() * speed
	body.move_and_slide()
