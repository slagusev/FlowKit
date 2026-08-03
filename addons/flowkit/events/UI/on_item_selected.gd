extends FKEvent
func get_description() -> String: return "Fires when ItemList item is selected. Index in system.last_item_index."
func get_id() -> String: return "on_itemlist_selected"
func get_name() -> String: return "On Item Selected"
func get_supported_types() -> Array[String]: return ["ItemList"]
func is_signal_event() -> bool: return true
var _callback: Callable
func setup(node: Node, trigger_callback: Callable, block_id: String = "") -> void:
	if not node is ItemList: return
	_callback = func(index: int):
		var system = node.get_tree().root.get_node_or_null("/root/FlowKitSystem") if node.get_tree() else null
		if system and system.has_method("set_var"): system.set_var("last_item_index", index)
		trigger_callback.call()
	if not node.item_selected.is_connected(_callback): node.item_selected.connect(_callback)
func teardown(node: Node, block_id: String = "") -> void:
	if is_instance_valid(node) and node is ItemList and _callback.is_valid() and node.item_selected.is_connected(_callback):
		node.item_selected.disconnect(_callback)
