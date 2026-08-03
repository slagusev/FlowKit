extends RefCounted
class_name FKMainEditorSheetFilter
## Sheet filter matching helpers extracted from FKMainEditor.


static func unit_ui_search_text(unit_ui: Node) -> String:
	var parts: PackedStringArray = []
	if unit_ui is FKEventRowUi:
		var e: FKEventUnit = unit_ui.get_block() as FKEventUnit
		if e:
			parts.append(e.event_id)
			parts.append(str(e.target_node))
			for cond in e.conditions:
				if cond:
					parts.append(cond.condition_id)
					parts.append(str(cond.target_node))
					for k in cond.inputs:
						parts.append(str(cond.inputs[k]))
			for act in e.actions:
				collect_action_search(act, parts)
	elif unit_ui is FKCommentUi:
		var c = unit_ui.get_block()
		if c and "text" in c:
			parts.append(str(c.text))
	elif unit_ui is FKGroupUi:
		var g = unit_ui.get_block()
		if g and "title" in g:
			parts.append(str(g.title))
		parts.append("group")
	if unit_ui is Control:
		collect_label_texts(unit_ui, parts)
	return " ".join(parts).to_lower()


static func collect_action_search(act: FKActionUnit, parts: PackedStringArray) -> void:
	if act == null:
		return
	parts.append(act.action_id)
	parts.append(str(act.target_node))
	for k in act.inputs:
		parts.append(str(act.inputs[k]))
	if act.is_branch:
		parts.append(act.branch_type)
		parts.append(act.branch_id)
		if act.branch_condition:
			parts.append(act.branch_condition.condition_id)
		for nested in act.branch_actions:
			collect_action_search(nested, parts)


static func collect_label_texts(node: Node, parts: PackedStringArray) -> void:
	if node is Label:
		parts.append((node as Label).text)
	for child in node.get_children():
		collect_label_texts(child, parts)


static func apply_filter(blocks_container: Node, empty_label: Node, filter_text: String) -> void:
	if blocks_container == null:
		return
	var filter := filter_text
	for child in blocks_container.get_children():
		if child == empty_label:
			continue
		if child is not Control:
			continue
		var ctrl := child as Control
		if filter.is_empty():
			ctrl.visible = true
			ctrl.modulate = Color.WHITE
			continue
		var haystack := unit_ui_search_text(child)
		var match_found := filter in haystack
		ctrl.visible = match_found
		ctrl.modulate = Color.WHITE if match_found else Color(1, 1, 1, 0.35)
