extends SceneTree
## Headless smoke: load core FlowKit classes without running demos.
## godot --headless --path . -s res://tools/ci_smoke.gd

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var ok := true
	var checks: PackedStringArray = []
	
	ok = _check("FKRegistry", "res://addons/flowkit/registry.gd", checks) and ok
	ok = _check("FKEventSheet", "res://addons/flowkit/resources/event_sheet.gd", checks) and ok
	ok = _check("FKBehaviorMeta", "res://addons/flowkit/runtime/behavior_meta.gd", checks) and ok
	ok = _check("FKSheetJsonIO", "res://addons/flowkit/editor/sheet_json_io.gd", checks) and ok
	ok = _check("FKExpressionAutocomplete", "res://addons/flowkit/editor/modals/expression_autocomplete.gd", checks) and ok
	ok = _check("FKTypedParamWidgets", "res://addons/flowkit/editor/modals/typed_param_widgets.gd", checks) and ok
	ok = _check("FKProviderCompat", "res://addons/flowkit/editor/provider_compat.gd", checks) and ok
	
	# Instantiation smoke
	var reg_script = load("res://addons/flowkit/registry.gd")
	if reg_script:
		var reg = reg_script.new()
		if reg.has_method("load_all"):
			reg.load_all()
			var n: int = reg.action_providers.size() + reg.event_providers.size()
			checks.append("registry providers total classes loaded: actions=%d events=%d" % [
				reg.action_providers.size(), reg.event_providers.size()
			])
			if n < 10:
				checks.append("FAIL: too few providers (%d)" % n)
				ok = false
		else:
			ok = false
			checks.append("FAIL: registry missing load_all")
	
	var sheet = load("res://addons/flowkit/resources/event_sheet.gd").new()
	var json_io = load("res://addons/flowkit/editor/sheet_json_io.gd")
	var json: String = ""
	if json_io:
		json = str(json_io.sheet_to_json(sheet))
	if not json.contains("flowkit_sheet_json"):
		ok = false
		checks.append("FAIL: sheet json format")
	else:
		checks.append("sheet json ok")
	
	print("=== FlowKit CI Smoke ===")
	for c in checks:
		print("  ", c)
	print("=== ", "PASS" if ok else "FAIL", " ===")
	quit(0 if ok else 1)

func _check(label: String, path: String, checks: PackedStringArray) -> bool:
	if not ResourceLoader.exists(path):
		checks.append("FAIL: missing %s (%s)" % [label, path])
		return false
	var s = load(path)
	if s == null:
		checks.append("FAIL: load %s" % label)
		return false
	checks.append("ok %s" % label)
	return true
