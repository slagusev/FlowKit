extends FKAction

func get_description() -> String:
	return "Enables or disables a BaseButton (Button, CheckBox, etc.)."

func get_id() -> String:
	return "ui_set_disabled"

func get_name() -> String:
	return "Set Disabled"

func get_supported_types() -> Array[String]:
	return ["BaseButton"]

func get_inputs() -> Array[FKActionInput]:
	return [_dis]

static var _dis: FKActionInput:
	get: return FKActionInput.new("Disabled", "bool", "true to disable.", false)

func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node is BaseButton:
		var v = _dis.get_val(inputs)
		var d := false
		if v is bool:
			d = v
		elif v is String:
			d = str(v).to_lower() in ["true", "1", "yes"]
		else:
			d = bool(v)
		(node as BaseButton).disabled = d