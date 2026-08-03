extends FKAction

func get_description() -> String:
	return "Sets the value of a ProgressBar or Range-based control."

func get_id() -> String:
	return "ui_set_progress"

func get_name() -> String:
	return "Set Progress Value"

func get_supported_types() -> Array[String]:
	return ["Range"]

func get_inputs() -> Array[FKActionInput]:
	return [_val]

static var _val: FKFloatActionInput:
	get: return FKFloatActionInput.new("Value", "New range value.")

func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node is Range:
		(node as Range).value = _val.get_val(inputs)