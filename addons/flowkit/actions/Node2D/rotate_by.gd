extends FKAction
func get_description() -> String: return "Rotates a Node2D by radians (relative)."
func get_id() -> String: return "node2d_rotate_by"
func get_name() -> String: return "Rotate By"
func get_supported_types() -> Array[String]: return ["Node2D"]
func get_inputs() -> Array[FKActionInput]: return [_a]
static var _a: FKFloatActionInput:
	get: return FKFloatActionInput.new("Radians", "Rotation delta in radians")
func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node is Node2D: (node as Node2D).rotate(_a.get_val(inputs))
