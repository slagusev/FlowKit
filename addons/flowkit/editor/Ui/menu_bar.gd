@tool
extends MenuBar
class_name FKMenuBar

signal new_sheet
signal save_sheet
signal generate_providers
signal generate_manifest
signal undo_requested
signal redo_requested
signal export_json_requested
signal import_json_requested
signal template_requested(template_id: String)

func _on_file_id_pressed(id: int) -> void:
	match id:
		0: # New Event Sheet
			emit_signal("new_sheet")
		1: # Save Event Sheet
			emit_signal("save_sheet")
		2: # Export JSON
			emit_signal("export_json_requested")
		3: # Import JSON
			emit_signal("import_json_requested")
		# 10+ reserved for templates (set from main_editor submenu)

func _on_template_id_pressed(id: int) -> void:
	# Template popup ids map via metadata string
	if has_meta("template_id_%d" % id):
		emit_signal("template_requested", str(get_meta("template_id_%d" % id)))

func _on_edit_id_pressed(id: int) -> void:
	match id:
		0: # Undo
			emit_signal("undo_requested")
		1: # Redo
			emit_signal("redo_requested")
		2: # Generate Providers (separator above)
			emit_signal("generate_providers")
		3: # Generate Manifest (for export)
			emit_signal("generate_manifest")
