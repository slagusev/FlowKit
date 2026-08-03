extends FKAction
func get_description() -> String: return "Tweens Node2D scale over duration seconds."
func get_id() -> String: return "node2d_tween_scale"
func get_name() -> String: return "Tween Scale"
func get_supported_types() -> Array[String]: return ["Node2D"]
func requires_multi_frames() -> bool: return true
func get_inputs() -> Array[FKActionInput]: return [_x, _y, _d]
static var _x: FKFloatActionInput:
	get: return FKFloatActionInput.new("X", "Target scale X", 1.0)
static var _y: FKFloatActionInput:
	get: return FKFloatActionInput.new("Y", "Target scale Y", 1.0)
static var _d: FKFloatActionInput:
	get: return FKFloatActionInput.new("Duration", "Seconds", 0.3)
func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if not node is Node2D or not is_instance_valid(node):
		exec_completed.emit(); return
	var target := Vector2(_x.get_val(inputs), _y.get_val(inputs))
	var dur := maxf(_d.get_val(inputs), 0.0)
	if dur <= 0.0:
		(node as Node2D).scale = target; exec_completed.emit(); return
	var tw := node.create_tween()
	tw.tween_property(node, "scale", target, dur)
	await tw.finished
	exec_completed.emit()
