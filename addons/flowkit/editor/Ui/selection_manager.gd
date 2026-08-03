extends RefCounted
class_name FKSelectionManager
## Multi-select for event rows / condition / action items in the main editor.

var primary_row: FKUnitUi = null
var primary_item: FKUnitUi = null
var selected_rows: Array = []  # Array[FKUnitUi]
var selected_items: Array = []  # Array[FKUnitUi]


func clear() -> void:
	for r in selected_rows:
		if is_instance_valid(r) and r.has_method("set_selected"):
			r.set_selected(false)
	for it in selected_items:
		if is_instance_valid(it) and it.has_method("set_selected"):
			it.set_selected(false)
	selected_rows.clear()
	selected_items.clear()
	primary_row = null
	primary_item = null


func select_row(row: FKUnitUi, additive: bool = false) -> void:
	if row == null:
		return
	if not additive:
		_clear_items()
		_clear_rows_except(null)
		selected_rows.clear()
	if row in selected_rows:
		if additive and selected_rows.size() > 1:
			selected_rows.erase(row)
			if row.has_method("set_selected"):
				row.set_selected(false)
			if primary_row == row:
				primary_row = selected_rows[0] if not selected_rows.is_empty() else null
			return
	else:
		selected_rows.append(row)
	primary_row = row
	primary_item = null
	if row.has_method("set_selected"):
		row.set_selected(true)


func select_item(item: FKUnitUi, additive: bool = false) -> void:
	if item == null:
		return
	if not additive:
		_clear_rows_except(null)
		selected_rows.clear()
		primary_row = null
		_clear_items_except(null)
		selected_items.clear()
	if item in selected_items:
		if additive and selected_items.size() > 1:
			selected_items.erase(item)
			if item.has_method("set_selected"):
				item.set_selected(false)
			if primary_item == item:
				primary_item = selected_items[0] if not selected_items.is_empty() else null
			return
	else:
		selected_items.append(item)
	primary_item = item
	if item.has_method("set_selected"):
		item.set_selected(true)


func _clear_rows_except(_keep) -> void:
	for r in selected_rows:
		if is_instance_valid(r) and r.has_method("set_selected"):
			r.set_selected(false)


func _clear_items() -> void:
	_clear_items_except(null)
	selected_items.clear()
	primary_item = null


func _clear_items_except(_keep) -> void:
	for it in selected_items:
		if is_instance_valid(it) and it.has_method("set_selected"):
			it.set_selected(false)


func has_selection() -> bool:
	return not selected_rows.is_empty() or not selected_items.is_empty()


func row_count() -> int:
	return selected_rows.size()


func item_count() -> int:
	return selected_items.size()
