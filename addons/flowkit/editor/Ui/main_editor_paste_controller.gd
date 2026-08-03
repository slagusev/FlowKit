extends RefCounted
class_name FKMainEditorPasteController
## Paste helpers extracted from FKMainEditor.

var editor: FKMainEditor


func setup(main: FKMainEditor) -> void:
	editor = main


func paste_events() -> void:
	if editor == null:
		return
	var new_events = editor.clipboard.paste_event()
	if new_events.is_empty():
		return
	editor._on_pre_ui_change()
	var insert_idx = editor.blocks_container.get_child_count()
	if editor.selected_row:
		insert_idx = editor.selected_row.get_index() + 1
	var first_row: FKUnitUi = null
	for ev in new_events:
		var row := editor._create_unit_ui(ev)
		editor.blocks_container.add_child(row)
		editor.blocks_container.move_child(row, insert_idx)
		insert_idx += 1
		if first_row == null:
			first_row = row
	if first_row:
		editor._on_row_selected(first_row)
	editor._on_ui_change_done()


func paste_actions() -> void:
	if editor == null:
		return
	var target_row = editor.selected_row
	if not target_row and editor.selected_item:
		target_row = editor._find_parent_event_row(editor.selected_item)
	if not target_row:
		return
	var new_actions = editor.clipboard.paste_action()
	if new_actions.is_empty():
		return
	editor._on_pre_ui_change()
	var target_branch = null
	if editor.selected_item:
		target_branch = editor._find_parent_branch(editor.selected_item)
	if target_branch:
		var branch_data = target_branch.get_block()
		for act in new_actions:
			branch_data.branch_actions.append(act)
		target_row.update_display()
		editor._on_row_selected(target_row)
		editor._on_ui_change_done()
		return
	var data := target_row.get_block() as FKEventUnit
	for act in new_actions:
		data.actions.append(act)
	target_row.update_display()
	editor._on_row_selected(target_row)
	editor._on_ui_change_done()


func paste_conditions() -> void:
	if editor == null:
		return
	var target_row = editor.selected_row
	if not target_row and editor.selected_item:
		target_row = editor._find_parent_event_row(editor.selected_item)
	if not target_row:
		return
	var new_conditions = editor.clipboard.paste_condition()
	if new_conditions.is_empty():
		return
	editor._on_pre_ui_change()
	var data := target_row.get_block() as FKEventUnit
	for cond in new_conditions:
		data.conditions.append(cond)
	target_row.update_display()
	editor._on_row_selected(target_row)
	editor._on_ui_change_done()


func paste_group() -> void:
	if editor == null:
		return
	var new_group := editor.clipboard.paste_group()
	if not new_group:
		return
	editor._on_pre_ui_change()
	var target_group = null
	if editor.selected_row is FKGroupUi:
		target_group = editor.selected_row
	elif editor.selected_row:
		var parent = editor.selected_row.get_parent()
		while parent:
			if parent is FKGroupUi:
				target_group = parent
				break
			parent = parent.get_parent()
	if target_group:
		if target_group.has_method("add_group_to_group"):
			target_group.add_group_to_group(new_group)
		else:
			var block = target_group.get_block()
			if block != null and "children" in block:
				block.children.append(new_group)
		target_group.update_display()
		editor._on_row_selected(target_group)
		editor._on_ui_change_done()
		return
	var group_node := editor.unit_ui_factory.unit_ui_from(new_group)
	editor._wire_signals(group_node)
	editor.blocks_container.add_child(group_node)
	editor._on_row_selected(group_node)
	editor._on_ui_change_done()
