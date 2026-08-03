extends FKAction

func get_description() -> String:
	return "Gives keyboard/UI focus to this Control."

func get_id() -> String:
	return "ui_grab_focus"

func get_name() -> String:
	return "Grab Focus"

func get_supported_types() -> Array[String]:
	return ["Control"]

func get_inputs() -> Array[FKActionInput]:
	return []

func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node is Control:
		(node as Control).grab_focus()