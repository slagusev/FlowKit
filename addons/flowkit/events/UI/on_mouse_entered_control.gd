extends FKEvent
func get_description() -> String: return "Fires when mouse enters Control (alias clarity for UI)."
func get_id() -> String: return "on_ui_mouse_entered_alias"
func get_name() -> String: return "On Mouse Entered (UI)"
func get_supported_types() -> Array[String]: return ["Control"]
func is_signal_event() -> bool: return true
var _callback: Callable
func setup(node: Node, trigger_callback: Callable, block_id: String = "") -> void:
	if not node is Control: return
	_callback = func(): trigger_callback.call()
	if not node.mouse_entered.is_connected(_callback): node.mouse_entered.connect(_callback)
func teardown(node: Node, block_id: String = "") -> void:
	if is_instance_valid(node) and node is Control and _callback.is_valid() and node.mouse_entered.is_connected(_callback):
		node.mouse_entered.disconnect(_callback)
