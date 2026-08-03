extends FKEvent
func get_description() -> String: return "Fires on Area2D input_event (click). Sets system.last_click_position."
func get_id() -> String: return "on_area2d_input_event"
func get_name() -> String: return "On Input Event (Area2D)"
func get_supported_types() -> Array[String]: return ["Area2D"]
func is_signal_event() -> bool: return true
var _callback: Callable
func setup(node: Node, trigger_callback: Callable, block_id: String = "") -> void:
	if not node is Area2D: return
	(node as Area2D).input_pickable = true
	_callback = func(viewport, event, shape_idx):
		if event is InputEventMouseButton and event.pressed:
			var system = node.get_tree().root.get_node_or_null("/root/FlowKitSystem") if node.get_tree() else null
			if system and system.has_method("set_var") and event is InputEventMouse:
				system.set_var("last_click_position", event.position)
			trigger_callback.call()
	if not node.input_event.is_connected(_callback): node.input_event.connect(_callback)
func teardown(node: Node, block_id: String = "") -> void:
	if is_instance_valid(node) and node is Area2D and _callback.is_valid() and node.input_event.is_connected(_callback):
		node.input_event.disconnect(_callback)
