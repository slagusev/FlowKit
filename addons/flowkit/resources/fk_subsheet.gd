@tool
extends Resource
class_name FKSubsheet
## Named reusable action sequence attached to an event sheet.

@export var subsheet_name: String = "New Subsheet"
@export var actions: Array[FKActionUnit] = []

## Parameter definitions for Call Subsheet with args.
## Each: {"name": String, "type": String, "default": Variant}
@export var parameters: Array[Dictionary] = []

func duplicate_subsheet():
	var copy = get_script().new()
	copy.subsheet_name = subsheet_name
	copy.parameters = parameters.duplicate(true)
	copy.actions = [] as Array[FKActionUnit]
	for act in actions:
		if act:
			var d := act.duplicate_block() as FKActionUnit
			if d:
				copy.actions.append(d)
	return copy

## Build name->default map for parameters.
func build_param_defaults() -> Dictionary:
	var result: Dictionary = {}
	for p in parameters:
		if p == null or not (p is Dictionary):
			continue
		var n: String = str(p.get("name", "")).strip_edges()
		if n.is_empty():
			continue
		result[n] = FKSheetVarDef.coerce_default(p.get("default", null), str(p.get("type", "Variant")))
	return result
