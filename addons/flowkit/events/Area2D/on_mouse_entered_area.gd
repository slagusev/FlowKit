extends FKEvent
func get_description() -> String: return "Fires when mouse enters Area2D (input_pickable must be on)."
func get_id() -> String: return "on_area2d_mouse_entered"
func get_name() -> String: return "On Mouse Entered (Area2D)"
func get_supported_types() -> Array[String]: return ["Area2D"]
func is_signal_event() -> bool: return true
var _callback: Callable
func setup(node: Node, trigger_callback: Callable, block_id: String = "") -> void:
	if not node is Area2D: return
	(node as Area2D).input_pickable = true
	_callback = func(): trigger_callback.call()
	if not node.mouse_entered.is_connected(_callback): node.mouse_entered.connect(_callback)
func teardown(node: Node, block_id: String = "") -> void:
	if is_instance_valid(node) and node is Area2D and _callback.is_valid() and node.mouse_entered.is_connected(_callback):
		node.mouse_entered.disconnect(_callback)
