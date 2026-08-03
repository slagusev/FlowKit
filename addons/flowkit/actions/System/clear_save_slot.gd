extends FKAction

func get_description() -> String:
	return "Deletes user://flowkit_save_<slot>.json if it exists."

func get_id() -> String:
	return "clear_save_slot"

func get_name() -> String:
	return "Clear Save Slot"

func get_supported_types() -> Array[String]:
	return ["System"]

func get_inputs() -> Array[FKActionInput]:
	return [_slot]

static var _slot: FKStringActionInput:
	get:
		return FKStringActionInput.new("Slot", "Save slot name", "default")

func execute(node: Node, inputs: Dictionary, _block_id: String = "") -> void:
	var slot: String = str(_slot.get_val(inputs)).strip_edges()
	if slot.is_empty():
		slot = "default"
	var path := "user://flowkit_save_%s.json" % slot
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
		print("[FlowKit] Cleared save slot → ", path)
