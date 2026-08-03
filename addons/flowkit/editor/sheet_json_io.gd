extends RefCounted
class_name FKSheetJsonIO
## Export / import event sheets as JSON for git-friendly diffs and backups.


static func sheet_to_json(sheet: FKEventSheet) -> String:
	if sheet == null:
		return "{}"
	var root := {
		"format": "flowkit_sheet_json",
		"version": 1,
		"sheet_var_defs": sheet.sheet_var_defs.duplicate(true),
		"item_order": sheet.item_order.duplicate(true),
		"events": [],
		"comments": [],
		"groups": [],
		"subsheets": []
	}
	for e in sheet.events:
		if e:
			root["events"].append(e.serialize())
	for c in sheet.comments:
		if c:
			root["comments"].append(c.serialize())
	for g in sheet.groups:
		if g:
			root["groups"].append(g.serialize())
	for s in sheet.subsheets:
		if s == null:
			continue
		var sd := {
			"subsheet_name": s.subsheet_name if "subsheet_name" in s else "",
			"parameters": s.parameters.duplicate(true) if "parameters" in s else [],
			"actions": []
		}
		if "actions" in s:
			for a in s.actions:
				if a:
					sd["actions"].append(a.serialize())
		root["subsheets"].append(sd)
	return JSON.stringify(root, "\t")


static func sheet_from_json(text: String) -> FKEventSheet:
	var parsed = JSON.parse_string(text)
	if not (parsed is Dictionary):
		return null
	var d: Dictionary = parsed
	var sheet := FKEventSheet.new()
	if d.get("sheet_var_defs") is Array:
		sheet.sheet_var_defs = [] as Array[Dictionary]
		for v in d.get("sheet_var_defs"):
			if v is Dictionary:
				sheet.sheet_var_defs.append(v)
	if d.get("item_order") is Array:
		sheet.item_order = [] as Array[Dictionary]
		for o in d.get("item_order"):
			if o is Dictionary:
				sheet.item_order.append(o)
	sheet.events = [] as Array[FKEventUnit]
	for ed in d.get("events", []):
		if ed is Dictionary:
			var e := FKEventUnit.new()
			e.deserialize(ed)
			sheet.events.append(e)
	sheet.comments = [] as Array[FKComment]
	for cd in d.get("comments", []):
		if cd is Dictionary:
			var c := FKComment.new()
			c.deserialize(cd)
			sheet.comments.append(c)
	sheet.groups = [] as Array[FKGroup]
	for gd in d.get("groups", []):
		if gd is Dictionary:
			var g := FKGroup.new()
			g.deserialize(gd)
			sheet.groups.append(g)
	sheet.subsheets = []
	var sub_script = load("res://addons/flowkit/resources/fk_subsheet.gd")
	for sd in d.get("subsheets", []):
		if not (sd is Dictionary):
			continue
		var sub = sub_script.new()
		sub.subsheet_name = str(sd.get("subsheet_name", "Subsheet"))
		if sd.get("parameters") is Array:
			sub.parameters = [] as Array[Dictionary]
			for p in sd.get("parameters"):
				if p is Dictionary:
					sub.parameters.append(p)
		sub.actions = [] as Array[FKActionUnit]
		for ad in sd.get("actions", []):
			if ad is Dictionary:
				var a := FKActionUnit.new()
				a.deserialize(ad)
				sub.actions.append(a)
		sheet.subsheets.append(sub)
	sheet.on_loaded_from_disk()
	return sheet


static func write_file(path: String, sheet: FKEventSheet) -> Error:
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		return FileAccess.get_open_error()
	f.store_string(sheet_to_json(sheet))
	return OK


static func read_file(path: String) -> FKEventSheet:
	if not FileAccess.file_exists(path):
		return null
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return null
	return sheet_from_json(f.get_as_text())
