extends FKBehavior

func get_description() -> String:
	return "Automatically increases a Range (ProgressBar/Slider) value over time."

func get_id() -> String:
	return "ui_auto_fill"

func get_name() -> String:
	return "UI Auto Fill"

func get_inputs() -> Array[Dictionary]:
	return [
		{"name": "per_second", "type": "float", "default": 10.0},
		{"name": "loop", "type": "bool", "default": false},
	]

func get_supported_types() -> Array[String]:
	return ["Range"]

func apply(node: Node, inputs: Dictionary) -> void:
	node.set_meta("flowkit_behavior_" + get_id(), inputs)

func remove(node: Node) -> void:
	var k := "flowkit_behavior_" + get_id()
	if node.has_meta(k): node.remove_meta(k)

func process(node: Node, delta: float, inputs: Dictionary) -> void:
	if not node is Range: return
	var r := node as Range
	r.value += float(inputs.get("per_second", 10.0)) * delta
	if r.value >= r.max_value and bool(inputs.get("loop", false)):
		r.value = r.min_value
