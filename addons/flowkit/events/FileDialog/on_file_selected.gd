extends FKEvent

func get_description() -> String:
	return "Fires when FileDialog selects a file. Path in system.last_file_path."

func get_id() -> String:
	return "on_file_selected"

func get_name() -> String:
	return "On File Selected"

func get_supported_types() -> Array[String]:
	return ["FileDialog"]

func is_signal_event() -> bool:
	return true

var _callback: Callable

func setup(node: Node, trigger_callback: Callable, block_id: String = "") -> void:
	if not node is FileDialog:
		return
	_callback = func(path: String):
		var system = node.get_tree().root.get_node_or_null("/root/FlowKitSystem") if node.get_tree() else null
		if system and system.has_method("set_var"):
			system.set_var("last_file_path", path)
		trigger_callback.call()
	if not node.file_selected.is_connected(_callback):
		node.file_selected.connect(_callback)

func teardown(node: Node, block_id: String = "") -> void:
	if is_instance_valid(node) and node is FileDialog and _callback.is_valid():
		if node.file_selected.is_connected(_callback):
			node.file_selected.disconnect(_callback)
