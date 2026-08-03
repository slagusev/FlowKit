extends FKAction
func get_description() -> String: return "Sets only the Y component of CharacterBody3D velocity."
func get_id() -> String: return "set_velocity_y_3d"
func get_name() -> String: return "Set Velocity Y (3D)"
func get_supported_types() -> Array[String]: return ["CharacterBody3D"]
func get_inputs() -> Array[FKActionInput]: return [_y]
static var _y: FKFloatActionInput:
	get: return FKFloatActionInput.new("Y", "Vertical velocity")
func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node is CharacterBody3D:
		var b := node as CharacterBody3D
		b.velocity.y = _y.get_val(inputs)
