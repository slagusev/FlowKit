extends FKBehavior

func get_description() -> String:
	return "Moves a PathFollow2D along its path at constant speed (progress units/sec)."

func get_id() -> String:
	return "path_follow_simple"

func get_name() -> String:
	return "Path Follow"

func get_inputs() -> Array[Dictionary]:
	return [
		{"name": "speed", "type": "float", "default": 100.0},
		{"name": "loop", "type": "bool", "default": true},
	]

func get_supported_types() -> Array[String]:
	return ["PathFollow2D"]

func apply(node: Node, inputs: Dictionary) -> void:
	node.set_meta("flowkit_behavior_" + get_id(), inputs)

func remove(node: Node) -> void:
	var k := "flowkit_behavior_" + get_id()
	if node.has_meta(k):
		node.remove_meta(k)

func process(node: Node, delta: float, inputs: Dictionary) -> void:
	if not node is PathFollow2D:
		return
	var pf := node as PathFollow2D
	var speed: float = float(inputs.get("speed", 100.0))
	pf.progress += speed * delta
	if not bool(inputs.get("loop", true)) and pf.progress_ratio >= 1.0:
		pf.progress_ratio = 1.0
