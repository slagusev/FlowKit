extends FKEvent

func get_description() -> String:
	return "Fires when a body stops contacting this RigidBody2D (needs contact_monitor)."

func get_id() -> String:
	return "on_rigidbody2d_body_exited"

func get_name() -> String:
	return "On Body Exited"

func get_supported_types() -> Array[String]:
	return ["RigidBody2D"]

func is_signal_event() -> bool:
	return true

var _callback: Callable

func setup(node: Node, trigger_callback: Callable, block_id: String = "") -> void:
	if not node is RigidBody2D:
		return
	var rb := node as RigidBody2D
	rb.contact_monitor = true
	if rb.max_contacts_reported < 1:
		rb.max_contacts_reported = 4
	_callback = func(body: Node):
		var system = node.get_tree().root.get_node_or_null("/root/FlowKitSystem") if node.get_tree() else null
		if system and system.has_method("set_var"):
			system.set_var("last_body", body)
		trigger_callback.call()
	if not rb.body_exited.is_connected(_callback):
		rb.body_exited.connect(_callback)

func teardown(node: Node, block_id: String = "") -> void:
	if is_instance_valid(node) and node is RigidBody2D and _callback.is_valid():
		if node.body_exited.is_connected(_callback):
			node.body_exited.disconnect(_callback)
