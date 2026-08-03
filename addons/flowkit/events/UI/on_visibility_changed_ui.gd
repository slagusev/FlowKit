extends FKEvent
func get_description() -> String: return "Fires when Control visibility_changed."
func get_id() -> String: return "on_ui_visibility_changed"
func get_name() -> String: return "On Visibility Changed (UI)"
func get_supported_types() -> Array[String]: return ["Control", "CanvasItem"]
func is_signal_event() -> bool: return true
var _callback: Callable
func setup(node: Node, trigger_callback: Callable, block_id: String = "") -> void:
	if not node is CanvasItem: return
	_callback = func(): trigger_callback.call()
	if not node.visibility_changed.is_connected(_callback): node.visibility_changed.connect(_callback)
func teardown(node: Node, block_id: String = "") -> void:
	if is_instance_valid(node) and node is CanvasItem and _callback.is_valid() and node.visibility_changed.is_connected(_callback):
		node.visibility_changed.disconnect(_callback)
