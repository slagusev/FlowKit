extends FKEvent
func get_description() -> String: return "Fires when mouse enters Area3D (input_ray_pickable)."
func get_id() -> String: return "on_area3d_mouse_entered"
func get_name() -> String: return "On Mouse Entered (Area3D)"
func get_supported_types() -> Array[String]: return ["Area3D"]
func is_signal_event() -> bool: return true
var _callback: Callable
func setup(node: Node, trigger_callback: Callable, block_id: String = "") -> void:
	if not node is Area3D: return
	(node as Area3D).input_ray_pickable = true
	_callback = func(): trigger_callback.call()
	if not node.mouse_entered.is_connected(_callback): node.mouse_entered.connect(_callback)
func teardown(node: Node, block_id: String = "") -> void:
	if is_instance_valid(node) and node is Area3D and _callback.is_valid() and node.mouse_entered.is_connected(_callback):
		node.mouse_entered.disconnect(_callback)
