extends FKEvent
func get_description() -> String: return "Fires when RigidBody3D contacts another body (enables contact_monitor)."
func get_id() -> String: return "on_rigidbody3d_body_entered"
func get_name() -> String: return "On Body Entered (3D Rigid)"
func get_supported_types() -> Array[String]: return ["RigidBody3D"]
func is_signal_event() -> bool: return true
var _callback: Callable
func setup(node: Node, trigger_callback: Callable, block_id: String = "") -> void:
	if not node is RigidBody3D: return
	var rb := node as RigidBody3D
	rb.contact_monitor = true
	if rb.max_contacts_reported < 1: rb.max_contacts_reported = 4
	_callback = func(body: Node):
		var system = node.get_tree().root.get_node_or_null("/root/FlowKitSystem") if node.get_tree() else null
		if system and system.has_method("set_var"): system.set_var("last_body", body)
		trigger_callback.call()
	if not rb.body_entered.is_connected(_callback): rb.body_entered.connect(_callback)
func teardown(node: Node, block_id: String = "") -> void:
	if is_instance_valid(node) and node is RigidBody3D and _callback.is_valid() and node.body_entered.is_connected(_callback):
		node.body_entered.disconnect(_callback)
