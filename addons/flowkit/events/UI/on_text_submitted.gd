extends FKEvent
func get_description() -> String: return "Fires when LineEdit submits (Enter). Text in system.last_submitted_text."
func get_id() -> String: return "on_text_submitted"
func get_name() -> String: return "On Text Submitted"
func get_supported_types() -> Array[String]: return ["LineEdit"]
func is_signal_event() -> bool: return true
var _callback: Callable
func setup(node: Node, trigger_callback: Callable, block_id: String = "") -> void:
	if not node is LineEdit: return
	_callback = func(text: String):
		var system = node.get_tree().root.get_node_or_null("/root/FlowKitSystem") if node.get_tree() else null
		if system and system.has_method("set_var"): system.set_var("last_submitted_text", text)
		trigger_callback.call()
	if not node.text_submitted.is_connected(_callback): node.text_submitted.connect(_callback)
func teardown(node: Node, block_id: String = "") -> void:
	if is_instance_valid(node) and node is LineEdit and _callback.is_valid() and node.text_submitted.is_connected(_callback):
		node.text_submitted.disconnect(_callback)
