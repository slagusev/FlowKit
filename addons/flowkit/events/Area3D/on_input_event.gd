extends FKEvent
func get_description() -> String: return "Fires on Area3D input_event click."
func get_id() -> String: return "on_area3d_input_event"
func get_name() -> String: return "On Input Event (Area3D)"
func get_supported_types() -> Array[String]: return ["Area3D"]
func is_signal_event() -> bool: return true
var _callback: Callable
func setup(node: Node, trigger_callback: Callable, block_id: String = "") -> void:
	if not node is Area3D: return
	(node as Area3D).input_ray_pickable = true
	_callback = func(camera, event, event_position, normal, shape_idx):
		if event is InputEventMouseButton and event.pressed:
			var system = node.get_tree().root.get_node_or_null("/root/FlowKitSystem") if node.get_tree() else null
			if system and system.has_method("set_var"):
				system.set_var("last_click_position_3d", event_position)
			trigger_callback.call()
	if not node.input_event.is_connected(_callback): node.input_event.connect(_callback)
func teardown(node: Node, block_id: String = "") -> void:
	if is_instance_valid(node) and node is Area3D and _callback.is_valid() and node.input_event.is_connected(_callback):
		node.input_event.disconnect(_callback)
