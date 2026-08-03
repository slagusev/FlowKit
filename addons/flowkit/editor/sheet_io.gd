##
## In charge of saving and loading Event Sheets to/from disk.
##

extends RefCounted
class_name FKSheetIO

## Project-local sheets (user content, version-control friendly).
const PROJECT_SHEET_DIR := "res://flowkit/event_sheets"
## Legacy location (still read for migration).
const LEGACY_SHEET_DIR := "res://addons/flowkit/saved/event_sheet"

const SETTING_SHEET_DIR := "flowkit/event_sheets/directory"

static func get_sheet_directory() -> String:
	if ProjectSettings.has_setting(SETTING_SHEET_DIR):
		var custom: String = str(ProjectSettings.get_setting(SETTING_SHEET_DIR))
		if not custom.is_empty():
			return custom
	return PROJECT_SHEET_DIR

func get_sheet_path(scene_uid: int, scene_name: String = "") -> String:
	if scene_uid == 0:
		return ""
	var dir := get_sheet_directory()
	if scene_name.is_empty():
		return "%s/%d.tres" % [dir, scene_uid]
	# Human-readable name + uid for uniqueness (issue #54 style).
	var safe_name := scene_name.validate_filename()
	if safe_name.is_empty():
		safe_name = "sheet"
	return "%s/%s_%d.tres" % [dir, safe_name, scene_uid]

func get_legacy_sheet_path(scene_uid: int) -> String:
	if scene_uid == 0:
		return ""
	return "%s/%d.tres" % [LEGACY_SHEET_DIR, scene_uid]

func _resolve_existing_path(scene_uid: int, scene_name: String = "") -> String:
	var primary := get_sheet_path(scene_uid, scene_name)
	if primary != "" and FileAccess.file_exists(primary):
		return primary
	# Fallback: uid-only name in project dir
	var uid_only := get_sheet_path(scene_uid, "")
	if uid_only != "" and FileAccess.file_exists(uid_only):
		return uid_only
	# Fallback: legacy addon path
	var legacy := get_legacy_sheet_path(scene_uid)
	if legacy != "" and FileAccess.file_exists(legacy):
		return legacy
	return primary

func load_sheet(scene_uid: int, scene_name: String = "") -> FKEventSheet:
	var sheet_path := _resolve_existing_path(scene_uid, scene_name)
	if sheet_path == "" or not FileAccess.file_exists(sheet_path):
		return null

	var sheet := ResourceLoader.load(sheet_path)
	if sheet is FKEventSheet:
		sheet.on_loaded_from_disk()
		return sheet
	return null

func save_sheet(scene_uid: int, sheet: FKEventSheet, scene_name: String = "") -> int:
	var sheet_path := get_sheet_path(scene_uid, scene_name)
	sheet.refresh()
	if sheet_path == "":
		print("[SheetIo] Returning err invalid param")
		return ERR_INVALID_PARAMETER

	var dir := sheet_path.get_base_dir()
	DirAccess.make_dir_recursive_absolute(dir)
	var err := ResourceSaver.save(sheet, sheet_path)
	if err == OK:
		# If we still have a legacy file, leave it (safe) but prefer new path next load.
		pass
	return err

func new_sheet() -> FKEventSheet:
	return FKEventSheet.new()

# -------------------------------------------------------------------
#  EVENT COPY (supports both old dict format and new FKUnit format)
# -------------------------------------------------------------------

func copy_event_block(data: FKEventUnit) -> FKEventUnit:
	if data == null:
		return null

	return data.duplicate_block()

# -------------------------------------------------------------------
#  ACTION COPY (supports nested branches)
# -------------------------------------------------------------------

func copy_action(act: FKActionUnit) -> FKActionUnit:
	if act == null:
		return null
	
	return act.duplicate_block()

# -------------------------------------------------------------------
#  GROUP COPY (supports both dict children and FKUnit children)
# -------------------------------------------------------------------

func copy_group_block(data: FKGroup) -> FKGroup:
	if data == null:
		return null

	var result := data.duplicate_block()
	return result
