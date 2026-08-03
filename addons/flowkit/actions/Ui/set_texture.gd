extends FKAction
func get_description() -> String: return "Loads a texture from res:// path onto TextureRect."
func get_id() -> String: return "ui_set_texture"
func get_name() -> String: return "Set Texture"
func get_supported_types() -> Array[String]: return ["TextureRect"]
func get_inputs() -> Array[FKActionInput]: return [_p]
static var _p: FKStringActionInput:
	get: return FKStringActionInput.new("Path", "res:// path to texture")
func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if not node is TextureRect: return
	var path := _p.get_val(inputs).strip_edges()
	if path.is_empty() or not ResourceLoader.exists(path):
		push_warning("[FlowKit] Set Texture: invalid path '%s'" % path); return
	var tex = load(path)
	if tex is Texture2D: (node as TextureRect).texture = tex
