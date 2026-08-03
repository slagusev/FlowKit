extends FKBehavior

func get_description() -> String:
	return "Flips AnimatedSprite2D / Sprite2D based on parent CharacterBody2D velocity.x."

func get_id() -> String:
	return "auto_flip_sprite"

func get_name() -> String:
	return "Auto Flip Sprite"

func get_inputs() -> Array[Dictionary]:
	return [{"name": "threshold", "type": "float", "default": 1.0}]

func get_supported_types() -> Array[String]:
	return ["AnimatedSprite2D", "Sprite2D"]

func apply(node: Node, inputs: Dictionary) -> void:
	node.set_meta("flowkit_behavior_" + get_id(), inputs)

func remove(node: Node) -> void:
	var k := "flowkit_behavior_" + get_id()
	if node.has_meta(k): node.remove_meta(k)

func process(node: Node, delta: float, inputs: Dictionary) -> void:
	var parent = node.get_parent()
	if parent is CharacterBody2D:
		var thr: float = float(inputs.get("threshold", 1.0))
		var vx: float = (parent as CharacterBody2D).velocity.x
		if absf(vx) > thr and "flip_h" in node:
			node.set("flip_h", vx < 0.0)
