extends FKEvent

func get_description() -> String:
	return "Fires when a physics body exits this Area3D. Body stored as system.last_body."

func get_id() -> String:
	return "on_body_exited_3d"

func get_name() -> String:
	return "On Body Exited (3D)"

func get_supported_types() -> Array[String]:
	return ["Area3D"]

func is_signal_event() -> bool:
	return true

var _callback: Callable

func setup(node: Node, trigger_callback: Callable, block_id: String = "") -> void:
	if not node is Area3D:
		return
	_callback = func(body: Node):
		var system = node.get_tree().root.get_node_or_null("/root/FlowKitSystem") if node.get_tree() else null
		if system and system.has_method("set_var"):
			system.set_var("last_body", body)
			system.set_var("last_body_name", body.name if body else "")
		trigger_callback.call()
	if not node.body_exited.is_connected(_callback):
		node.body_exited.connect(_callback)

func teardown(node: Node, block_id: String = "") -> void:
	if is_instance_valid(node) and node is Area3D and _callback.is_valid():
		if node.body_exited.is_connected(_callback):
			node.body_exited.disconnect(_callback)