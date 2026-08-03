extends FKEvent
func get_description() -> String: return "Fires when BaseButton is pressed down."
func get_id() -> String: return "on_button_down"
func get_name() -> String: return "On Button Down"
func get_supported_types() -> Array[String]: return ["BaseButton"]
func is_signal_event() -> bool: return true
var _callback: Callable
func setup(node: Node, trigger_callback: Callable, block_id: String = "") -> void:
	if not node is BaseButton: return
	_callback = func(): trigger_callback.call()
	if not node.button_down.is_connected(_callback): node.button_down.connect(_callback)
func teardown(node: Node, block_id: String = "") -> void:
	if is_instance_valid(node) and node is BaseButton and _callback.is_valid() and node.button_down.is_connected(_callback):
		node.button_down.disconnect(_callback)
