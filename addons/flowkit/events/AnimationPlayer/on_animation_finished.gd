extends FKEvent
func get_description() -> String: return "Fires when AnimationPlayer finishes. Name in system.last_animation."
func get_id() -> String: return "on_animation_finished_player"
func get_name() -> String: return "On Animation Finished"
func get_supported_types() -> Array[String]: return ["AnimationPlayer"]
func is_signal_event() -> bool: return true
var _callback: Callable
func setup(node: Node, trigger_callback: Callable, block_id: String = "") -> void:
	if not node is AnimationPlayer: return
	_callback = func(anim_name: StringName):
		var system = node.get_tree().root.get_node_or_null("/root/FlowKitSystem") if node.get_tree() else null
		if system and system.has_method("set_var"): system.set_var("last_animation", str(anim_name))
		trigger_callback.call()
	if not node.animation_finished.is_connected(_callback): node.animation_finished.connect(_callback)
func teardown(node: Node, block_id: String = "") -> void:
	if is_instance_valid(node) and node is AnimationPlayer and _callback.is_valid() and node.animation_finished.is_connected(_callback):
		node.animation_finished.disconnect(_callback)
