extends FKEvent
func get_description() -> String: return "Fires when ScrollContainer scroll ends (scroll_ended if available, else poll stop)."
func get_id() -> String: return "on_scroll_ended"
func get_name() -> String: return "On Scroll Ended"
func get_supported_types() -> Array[String]: return ["ScrollContainer"]
func is_signal_event() -> bool: return true
var _callback: Callable
func setup(node: Node, trigger_callback: Callable, block_id: String = "") -> void:
	if not node is ScrollContainer: return
	_callback = func(): trigger_callback.call()
	if node.has_signal("scroll_ended") and not node.is_connected("scroll_ended", _callback):
		node.connect("scroll_ended", _callback)
	elif node.has_signal("gui_input"):
		# fallback: no-op connect won't fire; use process poll via meta
		node.set_meta("fk_scroll_watch", true)
func teardown(node: Node, block_id: String = "") -> void:
	if is_instance_valid(node) and _callback.is_valid() and node.has_signal("scroll_ended") and node.is_connected("scroll_ended", _callback):
		node.disconnect("scroll_ended", _callback)
