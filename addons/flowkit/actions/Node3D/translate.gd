extends FKAction
func get_description() -> String: return "Translates a Node3D by a local offset."
func get_id() -> String: return "node3d_translate"
func get_name() -> String: return "Translate (3D)"
func get_supported_types() -> Array[String]: return ["Node3D"]
func get_inputs() -> Array[FKActionInput]: return [_x, _y, _z]
static var _x: FKFloatActionInput:
	get: return FKFloatActionInput.new("X", "Local X")
static var _y: FKFloatActionInput:
	get: return FKFloatActionInput.new("Y", "Local Y")
static var _z: FKFloatActionInput:
	get: return FKFloatActionInput.new("Z", "Local Z")
func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node is Node3D: (node as Node3D).translate(Vector3(_x.get_val(inputs), _y.get_val(inputs), _z.get_val(inputs)))
