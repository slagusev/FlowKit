extends FKAction

func get_description() -> String:
	return "Sets Range value (ProgressBar, Slider, SpinBox, etc.)."

func get_id() -> String:
	return "set_progress_value"

func get_name() -> String:
	return "Set Progress Value"

func get_supported_types() -> Array[String]:
	return ["Range"]

func get_inputs() -> Array[FKActionInput]:
	return [_val]

static var _val: FKFloatActionInput:
	get: return FKFloatActionInput.new("Value", "New range value", 0.0)

func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node is Range:
		(node as Range).value = float(_val.get_val(inputs))
