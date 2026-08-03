extends FKEvent

func get_description() -> String:
	return "Fires when a LineEdit or TextEdit loses focus."

func get_id() -> String:
	return "on_text_focus_exited"

func get_name() -> String:
	return "On Text Focus Exited"

func get_supported_types() -> Array[String]:
	return ["LineEdit", "TextEdit"]

func is_signal_event() -> bool:
	return true

var _callback: Callable

func setup(node: Node, trigger_callback: Callable, block_id: String = "") -> void:
	if node == null or not node.has_signal("focus_exited"):
		return
	_callback = func(): trigger_callback.call()
	if not node.focus_exited.is_connected(_callback):
		node.focus_exited.connect(_callback)

func teardown(node: Node, block_id: String = "") -> void:
	if is_instance_valid(node) and _callback.is_valid() and node.has_signal("focus_exited"):
		if node.focus_exited.is_connected(_callback):
			node.focus_exited.disconnect(_callback)

func poll(node: Node, inputs: Dictionary = {}, block_id: String = "") -> bool:
	return false
