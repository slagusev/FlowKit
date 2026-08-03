extends FKAction

func get_description() -> String:
	return "Waits N process frames before continuing this event's actions."

func get_id() -> String:
	return "wait_frames"

func get_name() -> String:
	return "Wait Frames"

func get_supported_types() -> Array[String]:
	return ["System", "Node"]

func requires_multi_frames() -> bool:
	return true

func get_inputs() -> Array[FKActionInput]:
	return [_frames]

static var _frames: FKIntActionInput:
	get:
		return FKIntActionInput.new("Frames", "Number of process frames to wait.", 1)

func execute(node: Node, inputs: Dictionary, _block_id: String = "") -> void:
	var n: int = int(_frames.get_val(inputs))
	if n < 0:
		n = 0
	var tree: SceneTree = null
	if node and is_instance_valid(node) and node.get_tree():
		tree = node.get_tree()
	elif Engine.get_main_loop() is SceneTree:
		tree = Engine.get_main_loop() as SceneTree
	if tree == null or n <= 0:
		exec_completed.emit()
		return
	for _i in n:
		await tree.process_frame
	exec_completed.emit()
