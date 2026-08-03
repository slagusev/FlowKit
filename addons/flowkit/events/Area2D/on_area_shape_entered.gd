extends FKEvent

func get_description() -> String:
	return "Fires when a shape enters this Area2D (area_shape_entered)."

func get_id() -> String:
	return "on_area_shape_entered"

func get_name() -> String:
	return "On Area Shape Entered"

func get_supported_types() -> Array[String]:
	return ["Area2D"]

func is_signal_event() -> bool:
	return true

var _callback: Callable

func setup(node: Node, trigger_callback: Callable, block_id: String = "") -> void:
	if not node is Area2D:
		return
	_callback = func(area_rid, area, area_shape_index, local_shape_index):
		var system = node.get_tree().root.get_node_or_null("/root/FlowKitSystem") if node.get_tree() else null
		if system and system.has_method("set_var"):
			system.set_var("last_area", area)
		trigger_callback.call()
	if not node.area_shape_entered.is_connected(_callback):
		node.area_shape_entered.connect(_callback)

func teardown(node: Node, block_id: String = "") -> void:
	if is_instance_valid(node) and node is Area2D and _callback.is_valid():
		if node.area_shape_entered.is_connected(_callback):
			node.area_shape_entered.disconnect(_callback)
