extends FKAction

func get_description() -> String:
	return "Waits until the target node emits a named signal (optional timeout in seconds)."

func get_id() -> String:
	return "await_signal"

func get_name() -> String:
	return "Await Signal"

func get_supported_types() -> Array[String]:
	return ["Node"]

func requires_multi_frames() -> bool:
	return true

func get_inputs() -> Array[FKActionInput]:
	return [_signal_input, _timeout_input]

static var _signal_input: FKStringActionInput:
	get:
		return FKStringActionInput.new("Signal", "Signal name on this node, e.g. timeout, finished, body_entered.")

static var _timeout_input: FKFloatActionInput:
	get:
		return FKFloatActionInput.new("Timeout", "Seconds to wait max (0 = forever).", 0.0)

func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	var sig_name: String = str(_signal_input.get_val(inputs)).strip_edges()
	var timeout: float = 0.0
	var tval = _timeout_input.get_val(inputs)
	if tval != null:
		timeout = float(tval)
	if node == null or sig_name.is_empty() or not is_instance_valid(node):
		exec_completed.emit()
		return
	if not node.has_signal(sig_name):
		push_warning("[FlowKit] Await Signal: node '%s' has no signal '%s'" % [node.name, sig_name])
		exec_completed.emit()
		return
	var tree := node.get_tree()
	if tree == null:
		exec_completed.emit()
		return
	if timeout <= 0.0:
		await Signal(node, sig_name)
		exec_completed.emit()
		return
	# Race: signal vs timeout (lambda accepts extra signal args)
	var done := {"v": false}
	var finish := func(_a = null, _b = null, _c = null, _d = null, _e = null, _f = null, _g = null, _h = null):
		done["v"] = true
	var err := node.connect(sig_name, finish, CONNECT_ONE_SHOT)
	if err != OK:
		push_warning("[FlowKit] Await Signal: failed to connect '%s' on %s" % [sig_name, node.name])
		exec_completed.emit()
		return
	var timer := tree.create_timer(timeout)
	timer.timeout.connect(func(): done["v"] = true, CONNECT_ONE_SHOT)
	while not done["v"]:
		if not is_instance_valid(node) or node.get_tree() == null:
			break
		await tree.process_frame
	if is_instance_valid(node) and node.is_connected(sig_name, finish):
		node.disconnect(sig_name, finish)
	exec_completed.emit()
