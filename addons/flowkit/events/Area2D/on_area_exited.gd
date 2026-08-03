extends FKEvent
func get_description() -> String: return "Fires when another Area2D exits this area."
func get_id() -> String: return "on_area_exited_2d"
func get_name() -> String: return "On Area Exited"
func get_supported_types() -> Array[String]: return ["Area2D"]
func is_signal_event() -> bool: return true
var _callback: Callable
func setup(node: Node, trigger_callback: Callable, block_id: String = "") -> void:
	if not node is Area2D: return
	_callback = func(area: Area2D):
		var system = node.get_tree().root.get_node_or_null("/root/FlowKitSystem") if node.get_tree() else null
		if system and system.has_method("set_var"):
			system.set_var("last_area", area)
		trigger_callback.call()
	if not node.area_exited.is_connected(_callback): node.area_exited.connect(_callback)
func teardown(node: Node, block_id: String = "") -> void:
	if is_instance_valid(node) and node is Area2D and _callback.is_valid() and node.area_exited.is_connected(_callback):
		node.area_exited.disconnect(_callback)
