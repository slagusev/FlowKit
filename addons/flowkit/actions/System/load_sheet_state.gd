extends FKAction

func get_description() -> String:
	return "Loads sheet variables from user://flowkit_save_<slot>.json."

func get_id() -> String:
	return "load_sheet_state"

func get_name() -> String:
	return "Load Sheet State"

func get_supported_types() -> Array[String]:
	return ["System"]

func get_inputs() -> Array[FKActionInput]:
	return [_slot]

static var _slot: FKStringActionInput:
	get: return FKStringActionInput.new("Slot", "Save slot name", "default")

func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	var slot: String = str(_slot.get_val(inputs)).strip_edges()
	if slot.is_empty():
		slot = "default"
	var path := "user://flowkit_save_%s.json" % slot
	if not FileAccess.file_exists(path):
		push_warning("[FlowKit] Load Sheet State: no file " + path)
		return
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return
	var parsed = JSON.parse_string(f.get_as_text())
	if not (parsed is Dictionary):
		return
	var system = node.get_tree().root.get_node_or_null("/root/FlowKitSystem") if node and node.get_tree() else null
	if system == null:
		return
	var d: Dictionary = parsed
	if d.get("vars") is Dictionary and system.has_method("set_sheet_var"):
		for k in d["vars"].keys():
			system.set_sheet_var(str(k), d["vars"][k])
	if d.get("families") is Dictionary and "families" in system:
		system.families = d["families"]
	if d.get("globals") is Dictionary and "variables" in system:
		for k in d["globals"].keys():
			system.variables[k] = d["globals"][k]
	print("[FlowKit] Loaded state ← ", path)
