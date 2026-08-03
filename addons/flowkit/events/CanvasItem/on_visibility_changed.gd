extends FKEvent
func get_description() -> String: return "Fires when CanvasItem visibility changes."
func get_id() -> String: return "on_visibility_changed"
func get_name() -> String: return "On Visibility Changed"
func get_supported_types() -> Array[String]: return ["CanvasItem"]
func is_signal_event() -> bool: return true
var _callback: Callable
func setup(node: Node, trigger_callback: Callable, block_id: String = "") -> void:
	if not node is CanvasItem: return
	_callback = func(): trigger_callback.call()
	if not node.visibility_changed.is_connected(_callback): node.visibility_changed.connect(_callback)
func teardown(node: Node, block_id: String = "") -> void:
	if is_instance_valid(node) and node is CanvasItem and _callback.is_valid() and node.visibility_changed.is_connected(_callback):
		node.visibility_changed.disconnect(_callback)
