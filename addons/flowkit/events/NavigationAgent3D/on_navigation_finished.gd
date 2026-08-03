extends FKEvent
func get_description() -> String: return "Fires when NavigationAgent3D navigation finishes."
func get_id() -> String: return "on_nav3d_finished"
func get_name() -> String: return "On Navigation Finished (3D)"
func get_supported_types() -> Array[String]: return ["NavigationAgent3D"]
func is_signal_event() -> bool: return true
var _callback: Callable
func setup(node: Node, trigger_callback: Callable, block_id: String = "") -> void:
	if not node is NavigationAgent3D: return
	_callback = func(): trigger_callback.call()
	if not node.navigation_finished.is_connected(_callback): node.navigation_finished.connect(_callback)
func teardown(node: Node, block_id: String = "") -> void:
	if is_instance_valid(node) and node is NavigationAgent3D and _callback.is_valid() and node.navigation_finished.is_connected(_callback):
		node.navigation_finished.disconnect(_callback)
