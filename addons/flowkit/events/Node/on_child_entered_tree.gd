extends FKEvent

func get_description() -> String:
	return "Fires when a child enters the tree under this node. Child in system.last_child."

func get_id() -> String:
	return "on_child_entered_tree"

func get_name() -> String:
	return "On Child Entered Tree"

func get_supported_types() -> Array[String]:
	return ["Node"]

func is_signal_event() -> bool:
	return true

var _callback: Callable

func setup(node: Node, trigger_callback: Callable, block_id: String = "") -> void:
	if node == null:
		return
	_callback = func(child: Node):
		var system = node.get_tree().root.get_node_or_null("/root/FlowKitSystem") if node.get_tree() else null
		if system and system.has_method("set_var"):
			system.set_var("last_child", child)
			system.set_var("last_child_name", child.name if child else "")
		trigger_callback.call()
	if not node.child_entered_tree.is_connected(_callback):
		node.child_entered_tree.connect(_callback)

func teardown(node: Node, block_id: String = "") -> void:
	if is_instance_valid(node) and _callback.is_valid():
		if node.child_entered_tree.is_connected(_callback):
			node.child_entered_tree.disconnect(_callback)
