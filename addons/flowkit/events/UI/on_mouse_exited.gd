extends FKEvent

func get_description() -> String:
	return "Fires when the mouse leaves this Control."

func get_id() -> String:
	return "on_mouse_exited_ui"

func get_name() -> String:
	return "On Mouse Exited"

func get_supported_types() -> Array[String]:
	return ["Control"]

func is_signal_event() -> bool:
	return true

var _callback: Callable

func setup(node: Node, trigger_callback: Callable, block_id: String = "") -> void:
	if not node is Control:
		return
	_callback = func(): trigger_callback.call()
	if not node.mouse_exited.is_connected(_callback):
		node.mouse_exited.connect(_callback)

func teardown(node: Node, block_id: String = "") -> void:
	if is_instance_valid(node) and node is Control and _callback.is_valid():
		if node.mouse_exited.is_connected(_callback):
			node.mouse_exited.disconnect(_callback)