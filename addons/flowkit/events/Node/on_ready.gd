extends FKEvent

func get_description() -> String:
	return "Runs once when the target node emits ready (or on the next frame if already ready)."

func get_id() -> String:
	return "on_ready"

func get_name() -> String:
	return "On Ready"

func get_supported_types() -> Array[String]:
	return ["Node"]

func get_inputs() -> Array:
	return []

func is_signal_event() -> bool:
	return true

var _callback: Callable
var _triggered: bool = false

func setup(node: Node, trigger_callback: Callable, block_id: String = "") -> void:
	if not node:
		return
	_triggered = false
	_callback = func():
		if _triggered:
			return
		_triggered = true
		trigger_callback.call()
	
	if node.is_node_ready():
		# Already ready at sheet setup — fire next frame so the tree is stable.
		if node.get_tree():
			node.get_tree().process_frame.connect(_callback, CONNECT_ONE_SHOT)
		else:
			_callback.call_deferred()
	else:
		if not node.ready.is_connected(_callback):
			node.ready.connect(_callback, CONNECT_ONE_SHOT)

func teardown(node: Node, block_id: String = "") -> void:
	if not is_instance_valid(node):
		return
	if _callback.is_valid() and node.ready.is_connected(_callback):
		node.ready.disconnect(_callback)
	if node.get_tree() and _callback.is_valid() and node.get_tree().process_frame.is_connected(_callback):
		node.get_tree().process_frame.disconnect(_callback)
