extends RefCounted
class_name FKObjectConfig
## Read/write flowkit_object meta (Object Mode packs + local rules).

const META_KEY := "flowkit_object"
const META_RUNTIME := "flowkit_object_runtime"


static func get_config(node: Node) -> Dictionary:
	if node == null or not node.has_meta(META_KEY):
		return _default()
	var raw = node.get_meta(META_KEY)
	if not (raw is Dictionary):
		return _default()
	var d: Dictionary = (raw as Dictionary).duplicate(true)
	if not d.has("version"):
		d["version"] = 1
	if not d.has("packs") or not (d["packs"] is Dictionary):
		d["packs"] = {}
	if not d.has("local_rules") or not (d["local_rules"] is Array):
		d["local_rules"] = []
	if not d.has("binds") or not (d["binds"] is Array):
		d["binds"] = []
	return d


static func set_config(node: Node, config: Dictionary) -> void:
	if node == null:
		return
	var d := config.duplicate(true)
	d["version"] = 1
	if not d.has("packs"):
		d["packs"] = {}
	if not d.has("local_rules"):
		d["local_rules"] = []
	if not d.has("binds"):
		d["binds"] = []
	node.set_meta(META_KEY, d)


static func _default() -> Dictionary:
	return {"version": 1, "packs": {}, "local_rules": [], "binds": [], "quick_notes": ""}


static func is_pack_enabled(node: Node, pack_id: String) -> bool:
	var packs: Dictionary = get_config(node).get("packs", {})
	if not packs.has(pack_id):
		return false
	var entry = packs[pack_id]
	if entry is Dictionary:
		return bool(entry.get("enabled", false))
	return false


static func set_pack(node: Node, pack_id: String, enabled: bool, options: Dictionary = {}) -> void:
	var cfg := get_config(node)
	var packs: Dictionary = cfg.get("packs", {})
	var prev: Dictionary = {}
	if packs.has(pack_id) and packs[pack_id] is Dictionary:
		prev = (packs[pack_id] as Dictionary).duplicate(true)
	var merged_opts: Dictionary = prev.get("options", {}) if prev.has("options") else {}
	if merged_opts is Dictionary:
		merged_opts = merged_opts.duplicate(true)
	else:
		merged_opts = {}
	for k in options.keys():
		merged_opts[k] = options[k]
	packs[pack_id] = {"enabled": enabled, "options": merged_opts}
	cfg["packs"] = packs
	set_config(node, cfg)


static func get_pack_options(node: Node, pack_id: String) -> Dictionary:
	var packs: Dictionary = get_config(node).get("packs", {})
	if packs.has(pack_id) and packs[pack_id] is Dictionary:
		var o = packs[pack_id].get("options", {})
		if o is Dictionary:
			return (o as Dictionary).duplicate(true)
	return {}


static func get_local_rules(node: Node) -> Array:
	var cfg := get_config(node)
	var rules = cfg.get("local_rules", [])
	return rules if rules is Array else []


static func set_local_rules(node: Node, rules: Array) -> void:
	var cfg := get_config(node)
	cfg["local_rules"] = rules
	set_config(node, cfg)


static func get_binds(node: Node) -> Array:
	var cfg := get_config(node)
	var b = cfg.get("binds", [])
	return b if b is Array else []


static func set_binds(node: Node, binds: Array) -> void:
	var cfg := get_config(node)
	cfg["binds"] = binds
	set_config(node, cfg)


static func add_bind(node: Node, var_name: String, path: String, max_var: String = "max_hp") -> void:
	var binds: Array = get_binds(node)
	# Replace same path
	var next: Array = []
	for b in binds:
		if b is Dictionary and str(b.get("path", "")) == path:
			continue
		next.append(b)
	next.append({"enabled": true, "var": var_name, "path": path, "max_var": max_var, "as_int": true})
	set_binds(node, next)


static func get_runtime(node: Node) -> Dictionary:
	if node == null or not node.has_meta(META_RUNTIME):
		return {}
	var r = node.get_meta(META_RUNTIME)
	return r.duplicate(true) if r is Dictionary else {}


static func set_runtime(node: Node, runtime: Dictionary) -> void:
	if node:
		node.set_meta(META_RUNTIME, runtime)


static func has_object_config(node: Node) -> bool:
	return node != null and node.has_meta(META_KEY)
