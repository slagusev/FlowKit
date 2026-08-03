extends FKEvent
func get_description() -> String: return "Fires when TileMapLayer emits changed."
func get_id() -> String: return "on_tilemaplayer_changed"
func get_name() -> String: return "On TileMap Changed"
func get_supported_types() -> Array[String]: return ["TileMapLayer"]
func is_signal_event() -> bool: return true
var _callback: Callable
func setup(node: Node, trigger_callback: Callable, block_id: String = "") -> void:
	if not node is TileMapLayer: return
	_callback = func(): trigger_callback.call()
	if node.has_signal("changed") and not node.is_connected("changed", _callback):
		node.connect("changed", _callback)
func teardown(node: Node, block_id: String = "") -> void:
	if is_instance_valid(node) and _callback.is_valid() and node.has_signal("changed") and node.is_connected("changed", _callback):
		node.disconnect("changed", _callback)
