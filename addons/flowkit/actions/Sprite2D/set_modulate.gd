extends FKAction
func get_description() -> String: return "Sets Sprite2D modulate color."
func get_id() -> String: return "sprite2d_set_modulate"
func get_name() -> String: return "Set Modulate"
func get_supported_types() -> Array[String]: return ["Sprite2D", "AnimatedSprite2D"]
func get_inputs() -> Array[FKActionInput]: return [_r, _g, _b, _a]
static var _r: FKFloatActionInput:
	get: return FKFloatActionInput.new("R", "", 1.0)
static var _g: FKFloatActionInput:
	get: return FKFloatActionInput.new("G", "", 1.0)
static var _b: FKFloatActionInput:
	get: return FKFloatActionInput.new("B", "", 1.0)
static var _a: FKFloatActionInput:
	get: return FKFloatActionInput.new("A", "", 1.0)
func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node is CanvasItem:
		(node as CanvasItem).modulate = Color(_r.get_val(inputs), _g.get_val(inputs), _b.get_val(inputs), _a.get_val(inputs))
