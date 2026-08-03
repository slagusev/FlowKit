extends FKAction

func get_description() -> String:
	return "Waits for a specified input action to be pressed before continuing."

func get_id() -> String:
	return "Wait For Input"

func get_name() -> String:
	return "Wait For Input"

func get_supported_types() -> Array:
	return ["System"]
	
func requires_multi_frames() -> bool:
	return true
	
func get_inputs() -> Array[FKActionInput]:
	return [_name_input]
	
static var _name_input: FKStringActionInput:
	get:
		return FKStringActionInput.new(
			"Input Binding Name",
			"Name from Project → Input Map. Must not be empty."
		)

func execute(target_node: Node, inputs: Dictionary, _str := "") -> void:
	var binding := str(_name_input.get_val(inputs)).strip_edges()
	var tree := target_node.get_tree() if target_node else null
	
	if binding.is_empty() or tree == null:
		push_warning("[FlowKit] Wait For Input: empty binding or invalid tree — skipping wait.")
		exec_completed.emit()
		return
	
	if not InputMap.has_action(binding):
		push_warning("[FlowKit] Wait For Input: action '%s' is not in the Input Map — skipping wait." % binding)
		exec_completed.emit()
		return
	
	# Safety cap so a typo / missing press never freezes the game forever.
	const MAX_WAIT_FRAMES := 60 * 60 * 10  # ~10 minutes at 60fps
	var frames_waited := 0
	
	while frames_waited < MAX_WAIT_FRAMES:
		if Input.is_action_just_pressed(binding):
			break
		frames_waited += 1
		await tree.process_frame
	
	if frames_waited >= MAX_WAIT_FRAMES:
		push_warning("[FlowKit] Wait For Input: timed out waiting for '%s'." % binding)
	
	exec_completed.emit()
