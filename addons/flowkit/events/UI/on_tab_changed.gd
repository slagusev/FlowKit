extends FKEvent
func get_description() -> String: return "Fires when TabContainer tab changes. Index in system.last_tab_index."
func get_id() -> String: return "on_tab_changed"
func get_name() -> String: return "On Tab Changed"
func get_supported_types() -> Array[String]: return ["TabContainer"]
func is_signal_event() -> bool: return true
var _callback: Callable
func setup(node: Node, trigger_callback: Callable, block_id: String = "") -> void:
	if not node is TabContainer: return
	_callback = func(tab: int):
		var system = node.get_tree().root.get_node_or_null("/root/FlowKitSystem") if node.get_tree() else null
		if system and system.has_method("set_var"): system.set_var("last_tab_index", tab)
		trigger_callback.call()
	if not node.tab_changed.is_connected(_callback): node.tab_changed.connect(_callback)
func teardown(node: Node, block_id: String = "") -> void:
	if is_instance_valid(node) and node is TabContainer and _callback.is_valid() and node.tab_changed.is_connected(_callback):
		node.tab_changed.disconnect(_callback)
