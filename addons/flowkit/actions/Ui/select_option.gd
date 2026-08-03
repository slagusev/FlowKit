extends FKAction
func get_description() -> String: return "Selects OptionButton item by index."
func get_id() -> String: return "ui_select_option"
func get_name() -> String: return "Select Option"
func get_supported_types() -> Array[String]: return ["OptionButton"]
func get_inputs() -> Array[FKActionInput]: return [_i]
static var _i: FKIntActionInput:
	get: return FKIntActionInput.new("Index", "Item index", 0)
func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node is OptionButton: (node as OptionButton).select(_i.get_val(inputs))
