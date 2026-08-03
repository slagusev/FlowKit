extends FKAction

func get_description() -> String:
	return "Sets a float parameter on AnimationTree (e.g. parameters/Idle_Walk/blend_amount)."

func get_id() -> String:
	return "animtree_set_blend"

func get_name() -> String:
	return "Set AnimTree Blend"

func get_supported_types() -> Array[String]:
	return ["AnimationTree"]

func get_inputs() -> Array[FKActionInput]:
	return [_path, _val]

static var _path: FKStringActionInput:
	get: return FKStringActionInput.new("ParamPath", "Full parameter path", "parameters/blend")

static var _val: FKFloatActionInput:
	get: return FKFloatActionInput.new("Value", "Float value", 0.0)

func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if not (node is AnimationTree):
		return
	var path: String = str(_path.get_val(inputs)).strip_edges()
	if path.is_empty():
		return
	(node as AnimationTree).set(path, float(_val.get_val(inputs)))
