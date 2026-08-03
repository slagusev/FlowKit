extends FKAction

func get_description() -> String:
	return "Toggles visibility of a CanvasItem."

func get_id() -> String:
	return "ui_toggle_visible"

func get_name() -> String:
	return "Toggle Visible"

func get_supported_types() -> Array[String]:
	return ["CanvasItem"]

func get_inputs() -> Array[FKActionInput]:
	return []

func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node is CanvasItem:
		(node as CanvasItem).visible = not (node as CanvasItem).visible