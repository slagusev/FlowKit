extends FKCondition

func get_description() -> String:
	return "True when NavigationAgent3D has finished navigation."

func get_id() -> String:
	return "nav3d_is_navigation_finished"

func get_name() -> String:
	return "Is Navigation Finished (3D)"

func get_inputs() -> Array[Dictionary]:
	return []

func get_supported_types() -> Array[String]:
	return ["NavigationAgent3D"]

func check(node: Node, inputs: Dictionary, block_id: String = "") -> bool:
	if node is NavigationAgent3D:
		var a := node as NavigationAgent3D
		if a.has_method("is_navigation_finished"):
			return a.is_navigation_finished()
		return a.is_target_reached()
	return false
