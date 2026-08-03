extends FKAction
func get_description() -> String: return "Sets horizontal/vertical flip on Sprite2D."
func get_id() -> String: return "sprite2d_set_flip"
func get_name() -> String: return "Set Flip"
func get_supported_types() -> Array[String]: return ["Sprite2D"]
func get_inputs() -> Array[FKActionInput]: return [_h, _v]
static var _h: FKActionInput:
	get: return FKActionInput.new("Flip H", "bool", "", false)
static var _v: FKActionInput:
	get: return FKActionInput.new("Flip V", "bool", "", false)
func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node is Sprite2D:
		var s := node as Sprite2D
		s.flip_h = bool(_h.get_val(inputs))
		s.flip_v = bool(_v.get_val(inputs))
