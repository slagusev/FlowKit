extends FKAction

func get_description() -> String:
	return "Instantiates a PackedScene from a resource path and adds it as a child of the current scene root (or Parent Path)."

func get_id() -> String:
	return "create_instance"

func get_name() -> String:
	return "Create Instance"

func get_supported_types() -> Array[String]:
	return ["System"]

func get_inputs() -> Array[FKActionInput]:
	return [_scene_path_input, _parent_path_input, _pos_x_input, _pos_y_input]

static var _scene_path_input: FKStringActionInput:
	get:
		return FKStringActionInput.new("Scene Path", "res:// path to a .tscn file.")

static var _parent_path_input: FKStringActionInput:
	get:
		return FKStringActionInput.new("Parent Path", "Optional parent NodePath relative to current scene. Empty = scene root.")

static var _pos_x_input: FKFloatActionInput:
	get:
		return FKFloatActionInput.new("X", "Optional position X if the instance is Node2D.")

static var _pos_y_input: FKFloatActionInput:
	get:
		return FKFloatActionInput.new("Y", "Optional position Y if the instance is Node2D.")

func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	var scene_path: String = str(_scene_path_input.get_val(inputs)).strip_edges()
	if scene_path.is_empty() or not ResourceLoader.exists(scene_path):
		push_warning("[FlowKit] Create Instance: invalid scene path '%s'." % scene_path)
		return
	
	var packed: PackedScene = load(scene_path) as PackedScene
	if packed == null:
		push_warning("[FlowKit] Create Instance: failed to load PackedScene at '%s'." % scene_path)
		return
	
	var instance: Node = packed.instantiate()
	var tree := node.get_tree() if node else null
	if tree == null:
		return
	
	var parent: Node = tree.current_scene
	var parent_path: String = str(_parent_path_input.get_val(inputs)).strip_edges()
	if not parent_path.is_empty() and tree.current_scene:
		var found := tree.current_scene.get_node_or_null(parent_path)
		if found:
			parent = found
	
	if parent == null:
		push_warning("[FlowKit] Create Instance: no parent found.")
		return
	
	parent.add_child(instance)
	
	if instance is Node2D:
		(instance as Node2D).global_position = Vector2(_pos_x_input.get_val(inputs), _pos_y_input.get_val(inputs))
	
	var system = tree.root.get_node_or_null("/root/FlowKitSystem")
	if system and system.has_method("set_var"):
		system.set_var("last_instance", instance)
		system.set_var("last_instance_name", instance.name)
