extends RefCounted
class_name FKMainEditorBranchController
## Branch-related workflow helpers extracted from FKMainEditor (debt D).

var editor: FKMainEditor


func setup(main: FKMainEditor) -> void:
	editor = main


func resolve_registry() -> FKRegistry:
	if editor and editor.editor_globals:
		return editor.editor_globals.registry
	return null


func start_branch_workflow(branch_id: String, target_row) -> void:
	if editor == null:
		return
	editor.pending_branch_id = branch_id
	editor.pending_target_row = target_row
	var registry := resolve_registry()
	var provider = registry.get_branch_provider(branch_id) if registry else null
	var input_type: String = "condition"
	if provider and provider.has_method("get_input_type"):
		input_type = provider.get_input_type()
	if input_type == "evaluation":
		editor.pending_block_type = "branch_evaluation"
		var inputs: Array = provider.get_inputs() if provider and provider.has_method("get_inputs") else []
		if inputs.size() > 0:
			editor.expression_modal.populate_inputs("", branch_id, inputs, {})
			editor._popup_centered_on_editor(editor.expression_modal)
		else:
			editor._finalize_branch_evaluation_creation({})
	else:
		editor._start_add_workflow("branch", target_row)


func create_new_cond_for_branch(inputs: Dictionary) -> FKConditionUnit:
	var cond := FKConditionUnit.new()
	cond.condition_id = editor.pending_id
	cond.target_node = NodePath(editor.pending_node_path)
	cond.inputs = inputs.duplicate(true)
	return cond


func create_new_branch_unit(cond: FKConditionUnit) -> FKActionUnit:
	var branch := FKActionUnit.new()
	branch.is_branch = true
	branch.branch_type = "if"
	branch.branch_id = editor.pending_branch_id
	branch.branch_condition = cond
	branch.branch_actions = [] as Array[FKActionUnit]
	return branch
