extends FKAction
func get_description() -> String: return "Sets editable on LineEdit/TextEdit."
func get_id() -> String: return "ui_set_editable"
func get_name() -> String: return "Set Editable"
func get_supported_types() -> Array[String]: return ["LineEdit", "TextEdit"]
func get_inputs() -> Array[FKActionInput]: return [_e]
static var _e: FKActionInput:
	get: return FKActionInput.new("Editable", "bool", "", true)
func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if "editable" in node: node.set("editable", bool(_e.get_val(inputs)))
