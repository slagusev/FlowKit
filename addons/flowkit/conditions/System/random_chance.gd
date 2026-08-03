extends FKCondition

func get_description() -> String:
	return "Returns true with the given probability (0.0–1.0). Evaluated each time the condition is checked."

func get_id() -> String:
	return "random_chance"

func get_name() -> String:
	return "Random Chance"

func get_inputs() -> Array[Dictionary]:
	return [
		{"name": "Chance", "type": "float", "description": "Probability from 0.0 (never) to 1.0 (always)."},
	]

func get_supported_types() -> Array[String]:
	return ["System"]

func check(node: Node, inputs: Dictionary, block_id: String = "") -> bool:
	var chance: float = float(inputs.get("Chance", 0.5))
	chance = clampf(chance, 0.0, 1.0)
	return randf() < chance
