extends FKAction

func get_description() -> String:
	return "Subtracts from Object Mode health (n_hp / flowkit_variables.hp)."

func get_id() -> String:
	return "damage_health"

func get_name() -> String:
	return "Damage Health"

func get_supported_types() -> Array[String]:
	return ["Node"]

func get_inputs() -> Array[FKActionInput]:
	return [_amount]

static var _amount: FKFloatActionInput:
	get: return FKFloatActionInput.new("Amount", "Damage amount", 10.0)

func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node == null:
		return
	var vars: Dictionary = {}
	if node.has_meta("flowkit_variables"):
		vars = node.get_meta("flowkit_variables", {}).duplicate(true)
	var hp := float(vars.get("hp", 0))
	hp -= float(_amount.get_val(inputs))
	vars["hp"] = hp
	node.set_meta("flowkit_variables", vars)
