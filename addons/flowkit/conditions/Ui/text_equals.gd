extends FKCondition

func get_description() -> String:
	return "True when the control text equals the given string."

func get_id() -> String:
	return "ui_text_equals"

func get_name() -> String:
	return "Text Equals"

func get_inputs() -> Array[Dictionary]:
	return [
		{"name": "Text", "type": "String", "description": "Expected text."},
	]

func get_supported_types() -> Array[String]:
	return ["Label", "RichTextLabel", "Button", "LineEdit", "TextEdit"]

func check(node: Node, inputs: Dictionary, block_id: String = "") -> bool:
	var expected := str(inputs.get("Text", ""))
	if "text" in node:
		return str(node.text) == expected
	return false