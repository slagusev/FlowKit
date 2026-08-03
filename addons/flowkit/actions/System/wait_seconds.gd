extends FKAction

func get_description() -> String:
	return "Waits a number of seconds (async; blocks further actions in this event until done)."

func get_id() -> String:
	return "wait_seconds"

func get_name() -> String:
	return "Wait Seconds"

func get_supported_types() -> Array[String]:
	return ["System", "Node"]

func requires_multi_frames() -> bool:
	return true

func get_inputs() -> Array[FKActionInput]:
	return [_sec]

static var _sec: FKFloatActionInput:
	get:
		return FKFloatActionInput.new("Seconds", "How long to wait.", 1.0)

func execute(node: Node, inputs: Dictionary, _block_id: String = "") -> void:
	var sec := float(_sec.get_val(inputs))
	if sec < 0.0:
		sec = 0.0
	var tree: SceneTree = null
	if node and is_instance_valid(node) and node.get_tree():
		tree = node.get_tree()
	elif Engine.get_main_loop() is SceneTree:
		tree = Engine.get_main_loop() as SceneTree
	if tree == null or sec <= 0.0:
		exec_completed.emit()
		return
	await tree.create_timer(sec).timeout
	exec_completed.emit()
