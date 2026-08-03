extends FKCondition

func get_description() -> String:
	return "True when NavigationAgent2D has finished navigation (or is target reached)."

func get_id() -> String:
	return "nav2d_is_navigation_finished"

func get_name() -> String:
	return "Is Navigation Finished (2D)"

func get_inputs() -> Array[Dictionary]:
	return []

func get_supported_types() -> Array[String]:
	return ["NavigationAgent2D"]

func check(node: Node, inputs: Dictionary, block_id: String = "") -> bool:
	if node is NavigationAgent2D:
		var a := node as NavigationAgent2D
		if a.has_method("is_navigation_finished"):
			return a.is_navigation_finished()
		return a.is_target_reached()
	return false
