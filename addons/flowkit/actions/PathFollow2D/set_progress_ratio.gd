extends FKAction
func get_description() -> String: return "Sets PathFollow2D progress_ratio (0-1)."
func get_id() -> String: return "pathfollow2d_set_progress_ratio"
func get_name() -> String: return "Set Progress Ratio"
func get_supported_types() -> Array[String]: return ["PathFollow2D"]
func get_inputs() -> Array[FKActionInput]: return [_r]
static var _r: FKFloatActionInput:
	get: return FKFloatActionInput.new("Ratio", "0.0 to 1.0", 0.0)
func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node is PathFollow2D: (node as PathFollow2D).progress_ratio = clampf(_r.get_val(inputs), 0.0, 1.0)
