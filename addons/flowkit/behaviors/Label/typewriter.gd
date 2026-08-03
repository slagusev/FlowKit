extends FKBehavior

func get_description() -> String:
	return "Typewriter effect: reveals Label text over time from meta flowkit_typewriter_full or current text."

func get_id() -> String:
	return "ui_typewriter"

func get_name() -> String:
	return "UI Typewriter"

func get_inputs() -> Array[Dictionary]:
	return [
		{"name": "chars_per_sec", "type": "float", "default": 30.0},
	]

func get_supported_types() -> Array[String]:
	return ["Label", "RichTextLabel"]

func apply(node: Node, inputs: Dictionary) -> void:
	node.set_meta("flowkit_behavior_" + get_id(), inputs)
	var full := ""
	if node.has_meta("flowkit_typewriter_full"):
		full = str(node.get_meta("flowkit_typewriter_full"))
	elif "text" in node:
		full = str(node.get("text"))
		node.set_meta("flowkit_typewriter_full", full)
	node.set_meta("fk_tw_t", 0.0)
	if "text" in node:
		node.set("text", "")

func remove(node: Node) -> void:
	for k in ["flowkit_behavior_"+get_id(), "fk_tw_t"]:
		if node.has_meta(k): node.remove_meta(k)

func process(node: Node, delta: float, inputs: Dictionary) -> void:
	if not ("text" in node): return
	var full: String = str(node.get_meta("flowkit_typewriter_full", ""))
	if full.is_empty(): return
	var t: float = float(node.get_meta("fk_tw_t", 0.0)) + delta
	node.set_meta("fk_tw_t", t)
	var n: int = int(t * float(inputs.get("chars_per_sec", 30.0)))
	n = mini(n, full.length())
	node.set("text", full.substr(0, n))
