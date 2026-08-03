extends FKCondition

func get_description() -> String:
	return "True when a BaseButton (toggle) is pressed/checked."

func get_id() -> String:
	return "ui_is_button_pressed"

func get_name() -> String:
	return "Is Button Pressed"

func get_inputs() -> Array[Dictionary]:
	return []

func get_supported_types() -> Array[String]:
	return ["BaseButton"]

func check(node: Node, inputs: Dictionary, block_id: String = "") -> bool:
	return node is BaseButton and (node as BaseButton).button_pressed