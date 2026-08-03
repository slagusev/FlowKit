extends RefCounted
class_name FKExpressionAutocomplete
## Suggest completions for expression editor based on prefix and editor context.


static func suggestions_for(prefix: String, editor_globals: Variant, selected_node: Node = null) -> PackedStringArray:
	var out: PackedStringArray = []
	var p := prefix.strip_edges()
	var base: PackedStringArray = PackedStringArray([
		"delta", "true", "false", "null", "current", "current.global_position",
		"r_value", "subsheet_return", "system.subsheet_return", "system.subsheet_params",
		"system.picked", "system.picked_count", "system.get_var(\"", "system.get_sheet_var(\"",
		"node.position", "node.position.x", "node.position.y", "node.rotation", "node.visible",
		"node.modulate", "node.velocity", "node.velocity.x", "node.velocity.y",
		"lerpf(", "move_toward(", "randf()", "randi_range(", "clamp(", "abs(", "str(", "float(", "int("
	])
	if editor_globals != null and "sheet_var_defs" in editor_globals:
		for def in editor_globals.sheet_var_defs:
			if def is Dictionary:
				var n: String = str(def.get("name", "")).strip_edges()
				if not n.is_empty():
					base.append("s_" + n)
					base.append(n)
	if editor_globals != null and "sheet_subsheets" in editor_globals:
		for sub in editor_globals.sheet_subsheets:
			if sub and "parameters" in sub:
				for param in sub.parameters:
					if param is Dictionary:
						var pn: String = str(param.get("name", "")).strip_edges()
						if not pn.is_empty():
							base.append("p_" + pn)
	if selected_node and selected_node.has_meta("flowkit_variables"):
		var vars: Dictionary = selected_node.get_meta("flowkit_variables", {})
		for vn in vars.keys():
			base.append("n_" + str(vn))
	# Filter by last token after operators
	var token := _last_token(p)
	if token.is_empty():
		return base.slice(0, mini(24, base.size()))
	var token_l := token.to_lower()
	for s in base:
		if str(s).to_lower().begins_with(token_l) or token_l in str(s).to_lower():
			out.append(s)
	if out.is_empty():
		return base.slice(0, mini(12, base.size()))
	return out


static func _last_token(text: String) -> String:
	if text.is_empty():
		return ""
	var i := text.length() - 1
	while i >= 0:
		var ch := text[i]
		if ch in [" ", "+", "-", "*", "/", "(", ")", ",", "=", "!", "<", ">", "&", "|", "\t"]:
			return text.substr(i + 1)
		i -= 1
	return text
