extends FKEvent
func get_description() -> String: return "Fires when RigidBody2D contacts another body (needs contact_monitor)."
func get_id() -> String: return "on_rigidbody2d_body_entered"
func get_name() -> String: return "On Body Entered"
func get_supported_types() -> Array[String]: return ["RigidBody2D"]
func is_signal_event() -> bool: return true
var _callback: Callable
func setup(node: Node, trigger_callback: Callable, block_id: String = "") -> void:
	if not node is RigidBody2D: return
	var rb := node as RigidBody2D
	rb.contact_monitor = true
	if rb.max_contacts_reported < 1: rb.max_contacts_reported = 4
	_callback = func(body: Node):
		var system = node.get_tree().root.get_node_or_null("/root/FlowKitSystem") if node.get_tree() else null
		if system and system.has_method("set_var"): system.set_var("last_body", body)
		trigger_callback.call()
	if not rb.body_entered.is_connected(_callback): rb.body_entered.connect(_callback)
func teardown(node: Node, block_id: String = "") -> void:
	if is_instance_valid(node) and node is RigidBody2D and _callback.is_valid() and node.body_entered.is_connected(_callback):
		node.body_entered.disconnect(_callback)
