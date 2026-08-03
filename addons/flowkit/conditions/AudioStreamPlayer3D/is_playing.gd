extends FKCondition
func get_description() -> String: return "True when AudioStreamPlayer3D is playing."
func get_id() -> String: return "audio3d_is_playing"
func get_name() -> String: return "Is Playing (3D Audio)"
func get_inputs() -> Array[Dictionary]: return []
func get_supported_types() -> Array[String]: return ["AudioStreamPlayer3D"]
func check(node: Node, inputs: Dictionary, block_id: String = "") -> bool:
	return node is AudioStreamPlayer3D and (node as AudioStreamPlayer3D).playing
