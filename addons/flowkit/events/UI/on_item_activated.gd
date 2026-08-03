extends FKEvent
func get_description() -> String: return "Fires when ItemList item is activated (double-click/enter)."
func get_id() -> String: return "on_itemlist_activated"
func get_name() -> String: return "On Item Activated"
func get_supported_types() -> Array[String]: return ["ItemList"]
func is_signal_event() -> bool: return true
var _callback: Callable
func setup(node: Node, trigger_callback: Callable, block_id: String = "") -> void:
	if not node is ItemList: return
	_callback = func(index: int):
		var system = node.get_tree().root.get_node_or_null("/root/FlowKitSystem") if node.get_tree() else null
		if system and system.has_method("set_var"): system.set_var("last_item_index", index)
		trigger_callback.call()
	if not node.item_activated.is_connected(_callback): node.item_activated.connect(_callback)
func teardown(node: Node, block_id: String = "") -> void:
	if is_instance_valid(node) and node is ItemList and _callback.is_valid() and node.item_activated.is_connected(_callback):
		node.item_activated.disconnect(_callback)
