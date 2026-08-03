extends FKAction

func get_description() -> String:
	return "Emits a named signal on this node (no arguments)."

func get_id() -> String:
	return "emit_signal"

func get_name() -> String:
	return "Emit Signal"

func get_supported_types() -> Array[String]:
	return ["Node"]

func get_inputs() -> Array[FKActionInput]:
	return [_signal_input]

static var _signal_input: FKStringActionInput:
	get:
		return FKStringActionInput.new("Signal", "Signal name to emit.")

func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	var sig_name: String = str(_signal_input.get_val(inputs)).strip_edges()
	if node == null or sig_name.is_empty():
		return
	if not node.has_signal(sig_name):
		push_warning("[FlowKit] Emit Signal: no signal '%s' on %s" % [sig_name, node.name])
		return
	node.emit_signal(sig_name)
