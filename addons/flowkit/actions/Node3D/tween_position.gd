extends FKAction
func get_description() -> String: return "Tweens Node3D global position."
func get_id() -> String: return "node3d_tween_position"
func get_name() -> String: return "Tween Position (3D)"
func get_supported_types() -> Array[String]: return ["Node3D"]
func requires_multi_frames() -> bool: return true
func get_inputs() -> Array[FKActionInput]: return [_x, _y, _z, _d]
static var _x: FKFloatActionInput:
	get: return FKFloatActionInput.new("X", "")
static var _y: FKFloatActionInput:
	get: return FKFloatActionInput.new("Y", "")
static var _z: FKFloatActionInput:
	get: return FKFloatActionInput.new("Z", "")
static var _d: FKFloatActionInput:
	get: return FKFloatActionInput.new("Duration", "", 0.3)
func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if not node is Node3D or not is_instance_valid(node):
		exec_completed.emit(); return
	var target := Vector3(_x.get_val(inputs), _y.get_val(inputs), _z.get_val(inputs))
	var dur := maxf(_d.get_val(inputs), 0.0)
	if dur <= 0.0:
		(node as Node3D).global_position = target; exec_completed.emit(); return
	var tw := node.create_tween()
	tw.tween_property(node, "global_position", target, dur)
	await tw.finished
	exec_completed.emit()
