extends RefCounted
class_name FKMainEditorHistory
## Undo/redo helpers extracted from FKMainEditor.

var editor: FKMainEditor


func setup(main: FKMainEditor) -> void:
	editor = main


func push_undo_state() -> void:
	if editor == null or not editor.is_fully_legit:
		return
	if editor._is_in_undo_redo or editor._is_in_editor_rebuild:
		return
	if editor.sheet_state_tracker == null or not editor.sheet_state_tracker.enabled:
		return
	var units := editor.blocks_container.units
	editor.sheet_state_tracker.record_snapshot(units)


func clear() -> void:
	if editor and editor.sheet_state_tracker:
		editor.sheet_state_tracker.clear()


func undo() -> void:
	if editor == null:
		return
	var tracker := editor.sheet_state_tracker
	if tracker == null or editor._is_in_editor_rebuild or not tracker.has_previous() \
	or editor._is_in_undo_redo or not tracker.enabled:
		return
	editor._is_in_editor_rebuild = true
	editor._is_in_undo_redo = true
	var current_units := editor.blocks_container.units
	var prev_state := tracker.get_previous_snapshot(current_units)
	var restored_units := ArrayUtils.get_fk_units_in(prev_state)
	editor._restore_unit_uis(restored_units)
	await editor.get_tree().process_frame
	editor._is_in_undo_redo = false
	editor._is_in_editor_rebuild = false


func redo() -> void:
	if editor == null:
		return
	var tracker := editor.sheet_state_tracker
	if tracker == null or not tracker.has_next() or editor._is_in_undo_redo \
	or not tracker.enabled or editor._is_in_editor_rebuild:
		return
	editor._is_in_editor_rebuild = true
	editor._is_in_undo_redo = true
	var next_snapshot := tracker._future.pop_back()
	var restored_units := ArrayUtils.get_fk_units_in(next_snapshot)
	editor._restore_unit_uis(restored_units)
	await editor.get_tree().process_frame
	var current_units := editor.blocks_container.units
	var current_snapshot := tracker._deep_copy_units(current_units)
	tracker._history.append(current_snapshot)
	editor._is_in_undo_redo = false
	editor._is_in_editor_rebuild = false
