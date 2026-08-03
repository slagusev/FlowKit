extends FKEvent

func get_description() -> String:
	return "Fires when a Range (Slider/ProgressBar/SpinBox) value changes. Value stored as system.last_range_value."

func get_id() -> String:
	return "on_range_value_changed"

func get_name() -> String:
	return "On Value Changed"

func get_supported_types() -> Array[String]:
	return ["Range"]

func is_signal_event() -> bool:
	return true

var _callback: Callable

func setup(node: Node, trigger_callback: Callable, block_id: String = "") -> void:
	if not node is Range:
		return
	_callback = func(value: float):
		var system = node.get_tree().root.get_node_or_null("/root/FlowKitSystem") if node.get_tree() else null
		if system and system.has_method("set_var"):
			system.set_var("last_range_value", value)
		trigger_callback.call()
	if not node.value_changed.is_connected(_callback):
		node.value_changed.connect(_callback)

func teardown(node: Node, block_id: String = "") -> void:
	if is_instance_valid(node) and node is Range and _callback.is_valid():
		if node.value_changed.is_connected(_callback):
			node.value_changed.disconnect(_callback)