extends FKAction
func get_description() -> String: return "Sets current tab index on TabContainer."
func get_id() -> String: return "ui_set_tab"
func get_name() -> String: return "Set Current Tab"
func get_supported_types() -> Array[String]: return ["TabContainer"]
func get_inputs() -> Array[FKActionInput]: return [_i]
static var _i: FKIntActionInput:
	get: return FKIntActionInput.new("Index", "Tab index", 0)
func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node is TabContainer: (node as TabContainer).current_tab = _i.get_val(inputs)
