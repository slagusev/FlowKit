extends FKEvent
func get_description() -> String: return "Fires when VisibleOnScreenNotifier3D enters view."
func get_id() -> String: return "on_screen_entered_3d"
func get_name() -> String: return "On Screen Entered (3D)"
func get_supported_types() -> Array[String]: return ["VisibleOnScreenNotifier3D"]
func is_signal_event() -> bool: return true
var _callback: Callable
func setup(node: Node, trigger_callback: Callable, block_id: String = "") -> void:
	if not node is VisibleOnScreenNotifier3D: return
	_callback = func(): trigger_callback.call()
	if not node.screen_entered.is_connected(_callback): node.screen_entered.connect(_callback)
func teardown(node: Node, block_id: String = "") -> void:
	if is_instance_valid(node) and node is VisibleOnScreenNotifier3D and _callback.is_valid() and node.screen_entered.is_connected(_callback):
		node.screen_entered.disconnect(_callback)
