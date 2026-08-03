extends FKBehavior

func get_description() -> String:
	return "Orbits Node3D around origin (or parent origin) on XZ plane."

func get_id() -> String:
	return "orbit_y_3d"

func get_name() -> String:
	return "Orbit Y (3D)"

func get_inputs() -> Array[Dictionary]:
	return [
		{"name": "radius", "type": "float", "default": 3.0},
		{"name": "radians_per_sec", "type": "float", "default": 1.0},
		{"name": "height", "type": "float", "default": 0.0},
	]

func get_supported_types() -> Array[String]:
	return ["Node3D"]

func apply(node: Node, inputs: Dictionary) -> void:
	node.set_meta("flowkit_behavior_" + get_id(), inputs)
	node.set_meta("fk_orbit_t", 0.0)

func remove(node: Node) -> void:
	for k in ["flowkit_behavior_"+get_id(), "fk_orbit_t"]:
		if node.has_meta(k): node.remove_meta(k)

func process(node: Node, delta: float, inputs: Dictionary) -> void:
	if not node is Node3D: return
	var t: float = float(node.get_meta("fk_orbit_t", 0.0)) + delta * float(inputs.get("radians_per_sec", 1.0))
	node.set_meta("fk_orbit_t", t)
	var r: float = float(inputs.get("radius", 3.0))
	var h: float = float(inputs.get("height", 0.0))
	(node as Node3D).position = Vector3(cos(t) * r, h, sin(t) * r)
