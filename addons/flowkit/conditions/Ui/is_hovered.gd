extends FKCondition
func get_description() -> String: return "True when mouse is over Control (approx via get_global_rect)."
func get_id() -> String: return "ui_is_hovered"
func get_name() -> String: return "Is Hovered"
func get_inputs() -> Array[Dictionary]: return []
func get_supported_types() -> Array[String]: return ["Control"]
func check(node: Node, inputs: Dictionary, block_id: String = "") -> bool:
	if not node is Control: return false
	var c := node as Control
	return c.get_global_rect().has_point(c.get_global_mouse_position())
