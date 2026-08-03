extends FKEvent

func get_description() -> String:
	return "Fires when HTTPRequest completes. Result in system.last_http_body / last_http_code."

func get_id() -> String:
	return "on_http_request_completed"

func get_name() -> String:
	return "On Request Completed"

func get_supported_types() -> Array[String]:
	return ["HTTPRequest"]

func is_signal_event() -> bool:
	return true

var _callback: Callable

func setup(node: Node, trigger_callback: Callable, block_id: String = "") -> void:
	if not node is HTTPRequest:
		return
	_callback = func(result, response_code, headers, body):
		var system = node.get_tree().root.get_node_or_null("/root/FlowKitSystem") if node.get_tree() else null
		if system and system.has_method("set_var"):
			system.set_var("last_http_code", response_code)
			system.set_var("last_http_body", body.get_string_from_utf8() if body is PackedByteArray else str(body))
			system.set_var("last_http_result", result)
		trigger_callback.call()
	if not node.request_completed.is_connected(_callback):
		node.request_completed.connect(_callback)

func teardown(node: Node, block_id: String = "") -> void:
	if is_instance_valid(node) and node is HTTPRequest and _callback.is_valid():
		if node.request_completed.is_connected(_callback):
			node.request_completed.disconnect(_callback)
