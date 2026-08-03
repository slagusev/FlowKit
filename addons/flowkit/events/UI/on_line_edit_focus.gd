extends FKEvent
func get_description() -> String: return "Fires when LineEdit gains focus."
func get_id() -> String: return "on_lineedit_focus"
func get_name() -> String: return "On LineEdit Focus"
func get_supported_types() -> Array[String]: return ["LineEdit"]
func is_signal_event() -> bool: return true
var _callback: Callable
func setup(node: Node, trigger_callback: Callable, block_id: String = "") -> void:
	if not node is LineEdit: return
	_callback = func(): trigger_callback.call()
	if not node.focus_entered.is_connected(_callback): node.focus_entered.connect(_callback)
func teardown(node: Node, block_id: String = "") -> void:
	if is_instance_valid(node) and node is LineEdit and _callback.is_valid() and node.focus_entered.is_connected(_callback):
		node.focus_entered.disconnect(_callback)
