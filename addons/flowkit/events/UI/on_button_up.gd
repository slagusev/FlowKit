extends FKEvent
func get_description() -> String: return "Fires when BaseButton is released."
func get_id() -> String: return "on_button_up"
func get_name() -> String: return "On Button Up"
func get_supported_types() -> Array[String]: return ["BaseButton"]
func is_signal_event() -> bool: return true
var _callback: Callable
func setup(node: Node, trigger_callback: Callable, block_id: String = "") -> void:
	if not node is BaseButton: return
	_callback = func(): trigger_callback.call()
	if not node.button_up.is_connected(_callback): node.button_up.connect(_callback)
func teardown(node: Node, block_id: String = "") -> void:
	if is_instance_valid(node) and node is BaseButton and _callback.is_valid() and node.button_up.is_connected(_callback):
		node.button_up.disconnect(_callback)
