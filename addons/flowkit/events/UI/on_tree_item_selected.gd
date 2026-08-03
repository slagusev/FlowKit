extends FKEvent
func get_description() -> String: return "Fires when Tree item is selected."
func get_id() -> String: return "on_tree_item_selected"
func get_name() -> String: return "On Tree Item Selected"
func get_supported_types() -> Array[String]: return ["Tree"]
func is_signal_event() -> bool: return true
var _callback: Callable
func setup(node: Node, trigger_callback: Callable, block_id: String = "") -> void:
	if not node is Tree: return
	_callback = func(): trigger_callback.call()
	if not node.item_selected.is_connected(_callback): node.item_selected.connect(_callback)
func teardown(node: Node, block_id: String = "") -> void:
	if is_instance_valid(node) and node is Tree and _callback.is_valid() and node.item_selected.is_connected(_callback):
		node.item_selected.disconnect(_callback)
