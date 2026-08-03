extends FKEvent

func get_description() -> String:
	return "Fires when VisibleOnScreenNotifier2D exits the screen."

func get_id() -> String:
	return "on_screen_exited"

func get_name() -> String:
	return "On Screen Exited"

func get_supported_types() -> Array[String]:
	return ["VisibleOnScreenNotifier2D"]

func is_signal_event() -> bool:
	return true

var _callback: Callable

func setup(node: Node, trigger_callback: Callable, block_id: String = "") -> void:
	if not node is VisibleOnScreenNotifier2D:
		return
	_callback = func(): trigger_callback.call()
	if not node.screen_exited.is_connected(_callback):
		node.screen_exited.connect(_callback)

func teardown(node: Node, block_id: String = "") -> void:
	if is_instance_valid(node) and node is VisibleOnScreenNotifier2D and _callback.is_valid():
		if node.screen_exited.is_connected(_callback):
			node.screen_exited.disconnect(_callback)
