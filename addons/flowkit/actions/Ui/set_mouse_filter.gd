extends FKAction
func get_description() -> String: return "Sets mouse_filter: 0=STOP, 1=PASS, 2=IGNORE."
func get_id() -> String: return "ui_set_mouse_filter"
func get_name() -> String: return "Set Mouse Filter"
func get_supported_types() -> Array[String]: return ["Control"]
func get_inputs() -> Array[FKActionInput]: return [_m]
static var _m: FKIntActionInput:
	get: return FKIntActionInput.new("Filter", "0 STOP, 1 PASS, 2 IGNORE", 0)
func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node is Control:
		(node as Control).mouse_filter = clampi(_m.get_val(inputs), 0, 2)
