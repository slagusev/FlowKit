extends FKCondition
func get_description() -> String: return "True when Node2D global Y is greater than value."
func get_id() -> String: return "node2d_pos_y_greater"
func get_name() -> String: return "Position Y Greater Than"
func get_inputs() -> Array[Dictionary]:
	return [{"name": "Value", "type": "float", "description": "Threshold Y"}]
func get_supported_types() -> Array[String]: return ["Node2D"]
func check(node: Node, inputs: Dictionary, block_id: String = "") -> bool:
	return node is Node2D and (node as Node2D).global_position.y > float(inputs.get("Value", 0.0))
