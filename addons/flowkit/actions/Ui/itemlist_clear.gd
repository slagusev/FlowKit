extends FKAction
func get_description() -> String: return "Clears all items from ItemList."
func get_id() -> String: return "ui_itemlist_clear"
func get_name() -> String: return "Clear Items"
func get_supported_types() -> Array[String]: return ["ItemList"]
func get_inputs() -> Array[FKActionInput]: return []
func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node is ItemList: (node as ItemList).clear()
