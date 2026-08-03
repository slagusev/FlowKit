extends FKAction

func get_description() -> String:
	return "Plays an animation on an AnimationPlayer by name."

func get_id() -> String:
	return "play_animation"

func get_name() -> String:
	return "Play Animation"

func get_supported_types() -> Array[String]:
	return ["AnimationPlayer"]

func get_inputs() -> Array[FKActionInput]:
	return [_name_input]

static var _name_input: FKStringActionInput:
	get:
		return FKStringActionInput.new("Animation", "Name of the animation to play.")

func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if not node is AnimationPlayer:
		return
	var anim_name: String = str(_name_input.get_val(inputs)).strip_edges()
	if anim_name.is_empty():
		return
	var player := node as AnimationPlayer
	if player.has_animation(anim_name):
		player.play(anim_name)
	else:
		push_warning("[FlowKit] Play Animation: animation '%s' not found on %s." % [anim_name, node.name])
