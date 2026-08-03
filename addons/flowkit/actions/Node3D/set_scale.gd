extends FKAction
func get_description() -> String: return "Sets scale of a Node3D."
func get_id() -> String: return "node3d_set_scale"
func get_name() -> String: return "Set Scale (3D)"
func get_supported_types() -> Array[String]: return ["Node3D"]
func get_inputs() -> Array[FKActionInput]: return [_x, _y, _z]
static var _x: FKFloatActionInput:
	get: return FKFloatActionInput.new("X", "", 1.0)
static var _y: FKFloatActionInput:
	get: return FKFloatActionInput.new("Y", "", 1.0)
static var _z: FKFloatActionInput:
	get: return FKFloatActionInput.new("Z", "", 1.0)
func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node is Node3D: (node as Node3D).scale = Vector3(_x.get_val(inputs), _y.get_val(inputs), _z.get_val(inputs))
