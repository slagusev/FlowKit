extends FKCondition
func get_description() -> String: return "True when CanvasItem is visible."
func get_id() -> String: return "canvasitem_is_visible"
func get_name() -> String: return "Is Visible (Canvas)"
func get_inputs() -> Array[Dictionary]: return []
func get_supported_types() -> Array[String]: return ["CanvasItem"]
func check(node: Node, inputs: Dictionary, block_id: String = "") -> bool:
	return node is CanvasItem and (node as CanvasItem).visible
