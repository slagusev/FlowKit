extends FKAction

func get_description() -> String:
	return "Saves current sheet variables (and optional families) to user://flowkit_save.json."

func get_id() -> String:
	return "save_sheet_state"

func get_name() -> String:
	return "Save Sheet State"

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
	var system = node.get_tree().root.get_node_or_null("/root/FlowKitSystem") if node and node.get_tree() else null
	if system == null:
		return
	var scene_path := ""
	if node.get_tree() and node.get_tree().current_scene:
		scene_path = str(node.get_tree().current_scene.scene_file_path)
	var data := {
		"version": 2,
		"slot": slot,
		"scene": scene_path,
		"saved_at": Time.get_datetime_string_from_system(),
		"vars": system.current_sheet_vars.duplicate(true) if "current_sheet_vars" in system else {},
		"families": system.families.duplicate(true) if "families" in system else {},
		"globals": system.variables.duplicate(true) if "variables" in system else {},
		"sheet_uid": int(system.current_sheet_uid) if "current_sheet_uid" in system else 0
	}
	var path := "user://flowkit_save_%s.json" % slot
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(data))
		if system.has_method("debug_push"):
			system.debug_push("save", "slot=%s path=%s" % [slot, path])
		print("[FlowKit] Saved state → ", path)
