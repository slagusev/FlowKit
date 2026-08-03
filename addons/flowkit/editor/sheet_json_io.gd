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


## Merge incoming into base: append events/comments/groups; merge vars & subsheets by name.
## Does not mutate inputs; returns a new sheet.
static func merge_sheets(base: FKEventSheet, incoming: FKEventSheet) -> FKEventSheet:
	if base == null and incoming == null:
		return FKEventSheet.new()
	if base == null:
		return incoming
	if incoming == null:
		return base
	var out := FKEventSheet.new()
	# Vars by name
	var var_by: Dictionary = {}
	for v in base.sheet_var_defs:
		if v is Dictionary:
			var_by[str(v.get("name", ""))] = (v as Dictionary).duplicate(true)
	for v2 in incoming.sheet_var_defs:
		if v2 is Dictionary:
			var nm := str(v2.get("name", ""))
			if nm.is_empty():
				continue
			if not var_by.has(nm):
				var_by[nm] = (v2 as Dictionary).duplicate(true)
	out.sheet_var_defs = [] as Array[Dictionary]
	for k in var_by.keys():
		if str(k).is_empty():
			continue
		out.sheet_var_defs.append(var_by[k])
	# Events append
	out.events = [] as Array[FKEventUnit]
	out.item_order = [] as Array[Dictionary]
	for e in base.events:
		if e:
			out.events.append(e)
			out.item_order.append({"type": "event", "index": out.events.size() - 1})
	for e2 in incoming.events:
		if e2:
			# Fresh block ids to avoid collisions
			if e2.has_method("ensure_block_id"):
				e2.block_id = ""
				e2.ensure_block_id()
			out.events.append(e2)
			out.item_order.append({"type": "event", "index": out.events.size() - 1})
	# Comments
	out.comments = [] as Array[FKComment]
	for c in base.comments:
		if c:
			out.comments.append(c)
	for c2 in incoming.comments:
		if c2:
			out.comments.append(c2)
	# Groups
	out.groups = [] as Array[FKGroup]
	for g in base.groups:
		if g:
			out.groups.append(g)
	for g2 in incoming.groups:
		if g2:
			out.groups.append(g2)
	# Subsheets by name (incoming fills gaps / does not overwrite existing names)
	var sub_by: Dictionary = {}
	for s in base.subsheets:
		if s != null and "subsheet_name" in s:
			sub_by[str(s.subsheet_name)] = s
	for s2 in incoming.subsheets:
		if s2 != null and "subsheet_name" in s2:
			var sn := str(s2.subsheet_name)
			if not sub_by.has(sn):
				sub_by[sn] = s2
	out.subsheets = []
	for k2 in sub_by.keys():
		out.subsheets.append(sub_by[k2])
	out.on_loaded_from_disk()
	return out
