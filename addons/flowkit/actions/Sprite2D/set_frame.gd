extends FKAction
func get_description() -> String: return "Sets the frame index of a Sprite2D (hframes/vframes)."
func get_id() -> String: return "sprite2d_set_frame"
func get_name() -> String: return "Set Frame"
func get_supported_types() -> Array[String]: return ["Sprite2D"]
func get_inputs() -> Array[FKActionInput]: return [_f]
static var _f: FKIntActionInput:
	get: return FKIntActionInput.new("Frame", "Frame index", 0)
func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node is Sprite2D: (node as Sprite2D).frame = _f.get_val(inputs)
