extends FKAction
func get_description() -> String: return "Tweens Control modulate."
func get_id() -> String: return "ui_tween_modulate"
func get_name() -> String: return "Tween Modulate (UI)"
func get_supported_types() -> Array[String]: return ["CanvasItem"]
func requires_multi_frames() -> bool: return true
func get_inputs() -> Array[FKActionInput]: return [_r, _g, _b, _a, _d]
static var _r: FKFloatActionInput:
	get: return FKFloatActionInput.new("R", "", 1.0)
static var _g: FKFloatActionInput:
	get: return FKFloatActionInput.new("G", "", 1.0)
static var _b: FKFloatActionInput:
	get: return FKFloatActionInput.new("B", "", 1.0)
static var _a: FKFloatActionInput:
	get: return FKFloatActionInput.new("A", "", 1.0)
static var _d: FKFloatActionInput:
	get: return FKFloatActionInput.new("Duration", "", 0.25)
func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if not node is CanvasItem or not is_instance_valid(node):
		exec_completed.emit(); return
	var col := Color(_r.get_val(inputs), _g.get_val(inputs), _b.get_val(inputs), _a.get_val(inputs))
	var dur := maxf(_d.get_val(inputs), 0.0)
	if dur <= 0.0:
		(node as CanvasItem).modulate = col; exec_completed.emit(); return
	var tw := node.create_tween()
	tw.tween_property(node, "modulate", col, dur)
	await tw.finished
	exec_completed.emit()
