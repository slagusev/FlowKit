extends FKAction
func get_description() -> String: return "Sets Control size."
func get_id() -> String: return "ui_set_size"
func get_name() -> String: return "Set Size"
func get_supported_types() -> Array[String]: return ["Control"]
func get_inputs() -> Array[FKActionInput]: return [_w, _h]
static var _w: FKFloatActionInput:
	get: return FKFloatActionInput.new("Width", "")
static var _h: FKFloatActionInput:
	get: return FKFloatActionInput.new("Height", "")
func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node is Control: (node as Control).size = Vector2(_w.get_val(inputs), _h.get_val(inputs))
