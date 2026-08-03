extends FKEvent

func get_description() -> String:
	return "Alias event for Timer timeout (same as On Timeout)."

func get_id() -> String:
	return "on_timer_timeout_alias"

func get_name() -> String:
	return "On Timer Timeout"

func get_supported_types() -> Array[String]:
	return ["Timer"]

func is_signal_event() -> bool:
	return true

var _callback: Callable

func setup(node: Node, trigger_callback: Callable, block_id: String = "") -> void:
	if not node is Timer:
		return
	_callback = func(): trigger_callback.call()
	if not node.timeout.is_connected(_callback):
		node.timeout.connect(_callback)

func teardown(node: Node, block_id: String = "") -> void:
	if is_instance_valid(node) and node is Timer and _callback.is_valid():
		if node.timeout.is_connected(_callback):
			node.timeout.disconnect(_callback)
