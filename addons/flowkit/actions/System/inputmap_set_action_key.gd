extends FKAction

func get_description() -> String:
	return "Rebinds an InputMap action to a single physical key (keycode as string name, e.g. KEY_SPACE)."

func get_id() -> String:
	return "inputmap_set_action_key"

func get_name() -> String:
	return "InputMap Set Action Key"

func get_supported_types() -> Array[String]:
	return ["System"]

func get_inputs() -> Array[FKActionInput]:
	return [_action, _key]

static var _action: FKStringActionInput:
	get: return FKStringActionInput.new("Action", "InputMap action name.")

static var _key: FKStringActionInput:
	get: return FKStringActionInput.new("Key", "Key string: A, Space, Escape, Enter, Left, …")

func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	var action: String = str(_action.get_val(inputs)).strip_edges()
	var key_s: String = str(_key.get_val(inputs)).strip_edges()
	if action.is_empty() or key_s.is_empty():
		return
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	# Clear existing events
	for ev in InputMap.action_get_events(action):
		InputMap.action_erase_event(action, ev)
	var ke := InputEventKey.new()
	ke.keycode = _parse_key(key_s)
	InputMap.action_add_event(action, ke)

func _parse_key(s: String) -> Key:
	var u := s.to_upper().replace("KEY_", "")
	match u:
		"SPACE": return KEY_SPACE
		"ENTER", "RETURN": return KEY_ENTER
		"ESCAPE", "ESC": return KEY_ESCAPE
		"LEFT": return KEY_LEFT
		"RIGHT": return KEY_RIGHT
		"UP": return KEY_UP
		"DOWN": return KEY_DOWN
		"SHIFT": return KEY_SHIFT
		"CTRL", "CONTROL": return KEY_CTRL
		"TAB": return KEY_TAB
		_:
			if u.length() == 1:
				return OS.find_keycode_from_string(u)
			return OS.find_keycode_from_string(u)
