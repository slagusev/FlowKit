extends FKEvent
func get_description() -> String: return "Fires when Popup/Window is hidden."
func get_id() -> String: return "on_popup_hide"
func get_name() -> String: return "On Popup Hide"
func get_supported_types() -> Array[String]: return ["Window", "Popup"]
func is_signal_event() -> bool: return true
var _callback: Callable
func setup(node: Node, trigger_callback: Callable, block_id: String = "") -> void:
	_callback = func(): trigger_callback.call()
	if node is Window:
		if not node.visibility_changed.is_connected(_callback):
			node.visibility_changed.connect(func():
				if not node.visible: trigger_callback.call()
			)
	elif node is Popup and node.has_signal("popup_hide"):
		if not node.is_connected("popup_hide", _callback):
			node.connect("popup_hide", _callback)
func teardown(node: Node, block_id: String = "") -> void:
	pass
