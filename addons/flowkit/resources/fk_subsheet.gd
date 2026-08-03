@tool
extends Resource
class_name FKSubsheet
## Named reusable action sequence attached to an event sheet.

@export var subsheet_name: String = "New Subsheet"
@export var actions: Array[FKActionUnit] = []

func duplicate_subsheet():
	var copy = get_script().new()
	copy.subsheet_name = subsheet_name
	copy.actions = [] as Array[FKActionUnit]
	for act in actions:
		if act:
			var d := act.duplicate_block() as FKActionUnit
			if d:
				copy.actions.append(d)
	return copy
