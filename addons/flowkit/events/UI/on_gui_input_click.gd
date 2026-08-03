extends FKEvent

func get_description() -> String:
	return "Fires when Control receives a left mouse button press via gui_input."

func get_id() -> String:
	return "on_gui_input_click"

func get_name() -> String:
	return "On GUI Click"

func get_supported_types() -> Array[String]:
	return ["Control"]

func is_signal_event() -> bool:
	return true

var _callback: Callable

func setup(node: Node, trigger_callback: Callable, block_id: String = "") -> void:
	if not node is Control:
		return
	_callback = func(event: InputEvent):
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			trigger_callback.call()
	if not node.gui_input.is_connected(_callback):
		node.gui_input.connect(_callback)

func teardown(node: Node, block_id: String = "") -> void:
	if is_instance_valid(node) and node is Control and _callback.is_valid():
		if node.gui_input.is_connected(_callback):
			node.gui_input.disconnect(_callback)
