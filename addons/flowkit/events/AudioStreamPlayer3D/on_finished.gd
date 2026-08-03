extends FKEvent
func get_description() -> String: return "Fires when AudioStreamPlayer3D finishes."
func get_id() -> String: return "on_audio3d_finished"
func get_name() -> String: return "On Finished (3D Audio)"
func get_supported_types() -> Array[String]: return ["AudioStreamPlayer3D"]
func is_signal_event() -> bool: return true
var _callback: Callable
func setup(node: Node, trigger_callback: Callable, block_id: String = "") -> void:
	if not node is AudioStreamPlayer3D: return
	_callback = func(): trigger_callback.call()
	if not node.finished.is_connected(_callback): node.finished.connect(_callback)
func teardown(node: Node, block_id: String = "") -> void:
	if is_instance_valid(node) and node is AudioStreamPlayer3D and _callback.is_valid() and node.finished.is_connected(_callback):
		node.finished.disconnect(_callback)
