extends FKEvent
func get_description() -> String: return "Fires when ColorPicker color changes. Color in system.last_color."
func get_id() -> String: return "on_color_changed"
func get_name() -> String: return "On Color Changed"
func get_supported_types() -> Array[String]: return ["ColorPicker", "ColorPickerButton"]
func is_signal_event() -> bool: return true
var _callback: Callable
func setup(node: Node, trigger_callback: Callable, block_id: String = "") -> void:
	_callback = func(color: Color = Color.WHITE):
		var system = node.get_tree().root.get_node_or_null("/root/FlowKitSystem") if node.get_tree() else null
		if system and system.has_method("set_var"): system.set_var("last_color", color)
		trigger_callback.call()
	if node is ColorPicker and not node.color_changed.is_connected(_callback):
		node.color_changed.connect(_callback)
	elif node is ColorPickerButton and not node.color_changed.is_connected(_callback):
		node.color_changed.connect(_callback)
func teardown(node: Node, block_id: String = "") -> void:
	if is_instance_valid(node) and _callback.is_valid():
		if node is ColorPicker and node.color_changed.is_connected(_callback): node.color_changed.disconnect(_callback)
		elif node is ColorPickerButton and node.color_changed.is_connected(_callback): node.color_changed.disconnect(_callback)
