extends FKEvent
func get_description() -> String: return "Fires when OptionButton selection changes. Index in system.last_option_index."
func get_id() -> String: return "on_option_selected"
func get_name() -> String: return "On Option Selected"
func get_supported_types() -> Array[String]: return ["OptionButton"]
func is_signal_event() -> bool: return true
var _callback: Callable
func setup(node: Node, trigger_callback: Callable, block_id: String = "") -> void:
	if not node is OptionButton: return
	_callback = func(index: int):
		var system = node.get_tree().root.get_node_or_null("/root/FlowKitSystem") if node.get_tree() else null
		if system and system.has_method("set_var"): system.set_var("last_option_index", index)
		trigger_callback.call()
	if not node.item_selected.is_connected(_callback): node.item_selected.connect(_callback)
func teardown(node: Node, block_id: String = "") -> void:
	if is_instance_valid(node) and node is OptionButton and _callback.is_valid() and node.item_selected.is_connected(_callback):
		node.item_selected.disconnect(_callback)
