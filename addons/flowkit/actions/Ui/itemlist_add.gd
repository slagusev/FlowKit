extends FKAction
func get_description() -> String: return "Adds an item to ItemList."
func get_id() -> String: return "ui_itemlist_add"
func get_name() -> String: return "Add Item"
func get_supported_types() -> Array[String]: return ["ItemList"]
func get_inputs() -> Array[FKActionInput]: return [_t]
static var _t: FKStringActionInput:
	get: return FKStringActionInput.new("Text", "Item text")
func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node is ItemList: (node as ItemList).add_item(_t.get_val(inputs))
