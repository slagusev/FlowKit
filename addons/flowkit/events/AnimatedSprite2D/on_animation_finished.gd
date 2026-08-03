extends FKEvent
func get_description() -> String: return "Fires when AnimatedSprite2D finishes an animation."
func get_id() -> String: return "on_animation_finished_sprite"
func get_name() -> String: return "On Animation Finished"
func get_supported_types() -> Array[String]: return ["AnimatedSprite2D"]
func is_signal_event() -> bool: return true
var _callback: Callable
func setup(node: Node, trigger_callback: Callable, block_id: String = "") -> void:
	if not node is AnimatedSprite2D: return
	_callback = func(): trigger_callback.call()
	if not node.animation_finished.is_connected(_callback): node.animation_finished.connect(_callback)
func teardown(node: Node, block_id: String = "") -> void:
	if is_instance_valid(node) and node is AnimatedSprite2D and _callback.is_valid() and node.animation_finished.is_connected(_callback):
		node.animation_finished.disconnect(_callback)
