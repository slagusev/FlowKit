extends FKAction

func get_description() -> String:
	return "Rotates Node3D to look at a world-space position."

func get_id() -> String:
	return "look_at_position_3d"

func get_name() -> String:
	return "Look At Position 3D"

func get_supported_types() -> Array[String]:
	return ["Node3D"]

func get_inputs() -> Array[FKActionInput]:
	return [_x, _y, _z, _up]

static var _x: FKFloatActionInput:
	get: return FKFloatActionInput.new("X", "Target X", 0.0)
static var _y: FKFloatActionInput:
	get: return FKFloatActionInput.new("Y", "Target Y", 0.0)
static var _z: FKFloatActionInput:
	get: return FKFloatActionInput.new("Z", "Target Z", 0.0)
static var _up: FKStringActionInput:
	get: return FKStringActionInput.new("Up", "Up axis: y | z", "y")

func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if not (node is Node3D):
		return
	var target := Vector3(float(_x.get_val(inputs)), float(_y.get_val(inputs)), float(_z.get_val(inputs)))
	var up_s := str(_up.get_val(inputs)).to_lower()
	var up := Vector3.UP if up_s != "z" else Vector3.FORWARD
	(node as Node3D).look_at(target, up)
