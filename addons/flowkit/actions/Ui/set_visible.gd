extends FKAction

func get_description() -> String:
	return "Shows or hides a CanvasItem / Control."

func get_id() -> String:
	return "ui_set_visible"

func get_name() -> String:
	return "Set Visible"

func get_supported_types() -> Array[String]:
	return ["CanvasItem"]

func get_inputs() -> Array[FKActionInput]:
	return [_vis]

static var _vis: FKActionInput:
	get: return FKActionInput.new("Visible", "bool", "true to show, false to hide.", true)

func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node is CanvasItem:
		var v = _vis.get_val(inputs)
		var visible_val := true
		if v is bool:
			visible_val = v
		elif v is String:
			visible_val = str(v).to_lower() in ["true", "1", "yes"]
		else:
			visible_val = bool(v)
		(node as CanvasItem).visible = visible_val