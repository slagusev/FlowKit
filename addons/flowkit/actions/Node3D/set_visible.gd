extends FKAction
func get_description() -> String: return "Shows or hides a Node3D (and children visibility)."
func get_id() -> String: return "node3d_set_visible"
func get_name() -> String: return "Set Visible (3D)"
func get_supported_types() -> Array[String]: return ["Node3D"]
func get_inputs() -> Array[FKActionInput]: return [_v]
static var _v: FKActionInput:
	get: return FKActionInput.new("Visible", "bool", "", true)
func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node is Node3D: (node as Node3D).visible = bool(_v.get_val(inputs))
