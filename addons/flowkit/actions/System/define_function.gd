extends FKAction

## Registers a named function on FlowKitSystem.
## The body is a GDScript expression evaluated when Call Function runs.
## Use `system`, `node`, `scene_root`, and any global vars inside the body.

func get_description() -> String:
	return "Defines a named function (body expression) that can be invoked with Call Function."

func get_id() -> String:
	return "define_function"

func get_name() -> String:
	return "Define Function"

func get_supported_types() -> Array[String]:
	return ["System"]

func get_inputs() -> Array[FKActionInput]:
	return [_name_input, _body_input]

static var _name_input: FKStringActionInput:
	get:
		return FKStringActionInput.new("Name", "Unique name of the function.")

static var _body_input: FKStringActionInput:
	get:
		return FKStringActionInput.new(
			"Body",
			"GDScript expression run when the function is called. Access system, node, scene_root."
		)

const FKExpressionEvaluator = preload("res://addons/flowkit/runtime/expression_evaluator.gd")

func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	var function_name: String = str(_name_input.get_val(inputs)).strip_edges()
	var body: String = str(_body_input.get_val(inputs))

	if function_name.is_empty():
		push_warning("[FlowKit] Define Function: empty name — ignored.")
		return

	var system: Node = node.get_tree().root.get_node_or_null("/root/FlowKitSystem") if node and node.get_tree() else null
	if system == null or not system.has_method("register_function"):
		push_error("[FlowKit] Define Function: FlowKitSystem unavailable.")
		return

	# Capture body + weak refs for later evaluation.
	var body_expr := body
	var captured_node: Node = node
	var cb := func(arg0 = null, arg1 = null, arg2 = null, arg3 = null):
		var tree_node: Node = captured_node if is_instance_valid(captured_node) else null
		var scene_root: Node = null
		if tree_node and tree_node.get_tree():
			scene_root = tree_node.get_tree().current_scene
		# Expose args as system vars for the expression if provided.
		if system and system.has_method("set_var"):
			if arg0 != null:
				system.set_var("arg0", arg0)
			if arg1 != null:
				system.set_var("arg1", arg1)
			if arg2 != null:
				system.set_var("arg2", arg2)
			if arg3 != null:
				system.set_var("arg3", arg3)
		return FKExpressionEvaluator.evaluate(body_expr, tree_node, scene_root, tree_node)

	system.register_function(function_name, cb)
