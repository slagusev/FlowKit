@tool
extends SceneTree
## Headless: godot --headless -s res://tools/generate_provider_matrix.gd
## Writes docs/PROVIDER_MATRIX.md listing all FlowKit providers.

const OUT_PATH := "res://docs/PROVIDER_MATRIX.md"
const ROOTS := {
	"Actions": "res://addons/flowkit/actions",
	"Conditions": "res://addons/flowkit/conditions",
	"Events": "res://addons/flowkit/events",
}

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var md := PackedStringArray()
	md.append("# FlowKit Provider Matrix")
	md.append("")
	md.append("Auto-generated. Do not edit by hand — run:")
	md.append("```")
	md.append("godot --headless -s res://tools/generate_provider_matrix.gd")
	md.append("```")
	md.append("")
	
	for section in ROOTS.keys():
		md.append("## %s" % section)
		md.append("")
		md.append("| ID | Name | Types | Path |")
		md.append("|----|------|-------|------|")
		var rows: Array = _scan(ROOTS[section])
		rows.sort_custom(func(a, b): return str(a.get("id", "")) < str(b.get("id", "")))
		for r in rows:
			md.append("| `%s` | %s | %s | `%s` |" % [
				str(r.get("id", "")).replace("|", "\\|"),
				str(r.get("name", "")).replace("|", "\\|"),
				str(r.get("types", "")).replace("|", "\\|"),
				str(r.get("path", "")).replace("res://addons/flowkit/", "")
			])
		md.append("")
		md.append("**Count:** %d" % rows.size())
		md.append("")
	
	var text := "\n".join(md) + "\n"
	var abs_dir := ProjectSettings.globalize_path("res://docs")
	DirAccess.make_dir_recursive_absolute(abs_dir)
	var f := FileAccess.open(OUT_PATH, FileAccess.WRITE)
	if f:
		f.store_string(text)
		f.close()
		print("[generate_provider_matrix] Wrote ", OUT_PATH, " (", text.length(), " chars)")
	else:
		push_error("Failed to write " + OUT_PATH)
	# Force exit even if autoloads keep the process alive
	quit()
	OS.set_exit_code(0)
	call_deferred("quit")

func _scan(path: String) -> Array:
	var out: Array = []
	_scan_dir(path, out)
	return out

func _scan_dir(path: String, out: Array) -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		return
	dir.list_dir_begin()
	var name := dir.get_next()
	while name != "":
		if name.begins_with("."):
			name = dir.get_next()
			continue
		var full := path.path_join(name)
		if dir.current_is_dir():
			_scan_dir(full, out)
		elif name.ends_with(".gd") and not name.ends_with(".uid"):
			var script: GDScript = load(full) as GDScript
			if script and script.can_instantiate():
				var inst = script.new()
				if inst.has_method("get_id") and inst.has_method("get_name"):
					var pid: String = str(inst.get_id())
					if pid.is_empty():
						continue  # base / abstract scripts
					var types := []
					if inst.has_method("get_supported_types"):
						types = inst.get_supported_types()
					var type_strs: PackedStringArray = []
					for t in types:
						type_strs.append(str(t))
					out.append({
						"id": pid,
						"name": inst.get_name(),
						"types": ", ".join(type_strs),
						"path": full,
					})
		name = dir.get_next()
	dir.list_dir_end()
