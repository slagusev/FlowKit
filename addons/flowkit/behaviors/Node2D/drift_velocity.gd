extends FKBehavior

func get_description() -> String:
	return "Moves Node2D by constant velocity every frame."

func get_id() -> String:
	return "drift_velocity"

func get_name() -> String:
	return "Drift Velocity"

func get_supported_types() -> Array[String]:
	return ["Node2D"]

func get_inputs() -> Array[Dictionary]:
	return [
		{"name": "vx", "type": "float", "default": 50.0},
		{"name": "vy", "type": "float", "default": 0.0}
	]

func apply(node: Node, inputs: Dictionary) -> void:
	node.set_meta("flowkit_behavior_" + get_id(), inputs)

func remove(node: Node) -> void:
	var k := "flowkit_behavior_" + get_id()
	if node.has_meta(k):
		node.remove_meta(k)

func process(node: Node, delta: float, inputs: Dictionary) -> void:
	if node is Node2D:
		var vx := float(inputs.get("vx", 50.0))
		var vy := float(inputs.get("vy", 0.0))
		(node as Node2D).position += Vector2(vx, vy) * delta
