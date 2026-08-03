extends FKEvent

func get_description() -> String:
	return "Fires when a physics body enters this Area2D. The body is available as system.get_var(\"last_body\")."

func get_id() -> String:
	return "on_body_entered"

func get_name() -> String:
	return "On Body Entered"

func get_supported_types() -> Array[String]:
	return ["Area2D"]

func is_signal_event() -> bool:
	return true

var _callback: Callable

func setup(node: Node, trigger_callback: Callable, block_id: String = "") -> void:
	if not node is Area2D:
		return
	_callback = func(body: Node):
		var system = node.get_tree().root.get_node_or_null("/root/FlowKitSystem") if node.get_tree() else null
		if system and system.has_method("set_var"):
			system.set_var("last_body", body)
			system.set_var("last_body_name", body.name if body else "")
		trigger_callback.call()
	if not node.body_entered.is_connected(_callback):
		node.body_entered.connect(_callback)

func teardown(node: Node, block_id: String = "") -> void:
	if is_instance_valid(node) and node is Area2D and _callback.is_valid():
		if node.body_entered.is_connected(_callback):
			node.body_entered.disconnect(_callback)
