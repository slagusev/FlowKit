extends FKEvent

func get_description() -> String:
	return "Fires when a CheckBox/CheckButton is toggled. State stored as system.last_toggle_state."

func get_id() -> String:
	return "on_checkbox_toggled"

func get_name() -> String:
	return "On Toggled"

func get_supported_types() -> Array[String]:
	return ["BaseButton"]

func is_signal_event() -> bool:
	return true

var _callback: Callable

func setup(node: Node, trigger_callback: Callable, block_id: String = "") -> void:
	if not node is BaseButton:
		return
	_callback = func(pressed: bool):
		var system = node.get_tree().root.get_node_or_null("/root/FlowKitSystem") if node.get_tree() else null
		if system and system.has_method("set_var"):
			system.set_var("last_toggle_state", pressed)
		trigger_callback.call()
	if not node.toggled.is_connected(_callback):
		node.toggled.connect(_callback)

func teardown(node: Node, block_id: String = "") -> void:
	if is_instance_valid(node) and node is BaseButton and _callback.is_valid():
		if node.toggled.is_connected(_callback):
			node.toggled.disconnect(_callback)