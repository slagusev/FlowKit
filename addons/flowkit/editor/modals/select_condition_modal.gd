@tool
extends FKModalWindow
class_name FKSelectConditionModal

var selected_node_path: String = ""
var selected_node_class: String = ""
var available_conditions: Array = []

@export var search_box: LineEdit
@export var item_list: ItemList
@export var description_label: Label
@export var recent_item_list: ItemList
@export var desc_panel: Panel
@export var desc_panel_style: StyleBoxFlat

const FavoritesScript = preload("res://addons/flowkit/editor/modals/favorites_manager.gd")

var _all_items_cache: Array = []
var _recent_items_manager: Variant = null
var _favorites = null


func _toggle_subs(should_sub: bool):
	if should_sub and not _is_subbed:
		search_box.text_changed.connect(_on_search_text_changed)
		item_list.item_activated.connect(_on_item_activated)
		item_list.item_selected.connect(_on_item_selected)
		item_list.gui_input.connect(_on_item_list_gui_input)
		recent_item_list.item_activated.connect(_on_recent_item_activated)
	elif _is_subbed and !should_sub:
		search_box.text_changed.disconnect(_on_search_text_changed)
		item_list.item_activated.disconnect(_on_item_activated)
		item_list.item_selected.disconnect(_on_item_selected)
		if item_list.gui_input.is_connected(_on_item_list_gui_input):
			item_list.gui_input.disconnect(_on_item_list_gui_input)
		recent_item_list.item_activated.disconnect(_on_recent_item_activated)
	else:
		return
		
	_is_subbed = should_sub

func _on_item_list_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_RIGHT or (event.button_index == MOUSE_BUTTON_LEFT and event.ctrl_pressed):
			var idx := item_list.get_item_at_position(event.position, true)
			if idx < 0:
				return
			var meta = item_list.get_item_metadata(idx)
			if meta == null or not (meta is Dictionary):
				return
			var cid: String = str(meta.get("id", ""))
			var cname := item_list.get_item_text(idx).replace("★ ", "")
			if _favorites and not cid.is_empty():
				_favorites.toggle_condition(cid, cname)
				_update_list(search_box.text if search_box else "")
				get_viewport().set_input_as_handled()
	

func _enter_tree() -> void:
	super._enter_tree()
	
	if is_editor_preview or is_fully_legit:
		return
	
	_recent_items_manager = FKRecentItemsManagerUi.new()
	_favorites = FavoritesScript.new()
	_load_available_conditions()

func _ensure_export_fields_filled():
	var path: String
	if not search_box:
		path = "VBoxContainer/SearchBox"
		search_box = get_node(path)
	
	if not item_list:
		path = "VBoxContainer/HSplitContainer/MainPanel/MainVBox/ItemList"
		item_list = get_node(path)
		
	if not description_label:
		path = "VBoxContainer/HSplitContainer/MainPanel/MainVBox/DescriptionPanel/" +\
		"ScrollContainer/DescriptionLabel"
		description_label = get_node(path)
		
	if not recent_item_list:
		path = "VBoxContainer/HSplitContainer/RecentPanel/RecentVBox/RecentItemList"
		recent_item_list = get_node(path)
		
	if not desc_panel:
		path = "VBoxContainer/HSplitContainer/MainPanel/MainVBox/DescriptionPanel"
		desc_panel = get_node(path)
			
func _set_desc_panel_style():
	if not desc_panel_style:
		desc_panel_style = StyleBoxFlat.new()
		desc_panel_style.bg_color = Color(0.2, 0.2, 0.2, 0.8)
	desc_panel.add_theme_stylebox_override("panel", desc_panel_style)
	

func _load_available_conditions() -> void:
	"""Load conditions from FKRegistry (no per-modal disk scan)."""
	available_conditions.clear()
	if editor_globals and editor_globals.registry:
		available_conditions = FKProviderCompat.providers_from_registry(editor_globals.registry, "condition")
	print("[FKSelectConditionModal]: Loaded ", available_conditions.size(), " conditions (registry)")

func populate_conditions(node_path: String, node_class: String) -> void:
	"""Populate the list with conditions compatible with the selected node."""
	selected_node_path = node_path
	selected_node_class = node_class
	_load_available_conditions()
	
	if not item_list:
		return
	
	_all_items_cache.clear()
	description_label.text = ""
	
	# Filter conditions that support this node type
	for condition in available_conditions:
		var supported_types = condition.get_supported_types()
		if _is_node_compatible(node_class, supported_types):
			var condition_name = condition.get_name()
			var condition_id = condition.get_id()
			var condition_desc := ""
			if condition.has_method("get_description"):
				condition_desc = str(condition.get_description())
			
			var cat := "General"
			if supported_types.size() > 0:
				cat = str(supported_types[0])
			_all_items_cache.append({
				"name": condition_name,
				"id": condition_id,
				"description": condition_desc,
				"category": cat,
				"metadata": {"id": condition_id, "inputs": condition.get_inputs()}
			})
	
	_all_items_cache.sort_custom(func(a, b):
		var af: bool = _favorites != null and _favorites.is_condition_favorite(str(a.get("id", "")))
		var bf: bool = _favorites != null and _favorites.is_condition_favorite(str(b.get("id", "")))
		if af != bf:
			return af
		var ca := str(a.get("category", ""))
		var cb := str(b.get("category", ""))
		if ca != cb:
			return ca < cb
		return str(a["name"]).to_lower() < str(b["name"]).to_lower()
	)
	_update_list()
	_populate_recent_list()
	if search_box:
		search_box.clear()
		search_box.grab_focus()

func _update_list(filter_text: String = "") -> void:
	item_list.clear()
	var filter_lower = filter_text.to_lower().strip_edges()
	var last_cat := ""
	
	for item in _all_items_cache:
		var haystack := (
			str(item.get("name", "")) + " " +
			str(item.get("id", "")) + " " +
			str(item.get("category", "")) + " " +
			str(item.get("description", ""))
		).to_lower()
		if filter_text.is_empty() or filter_lower in haystack:
			var cat := str(item.get("category", "General"))
			if cat != last_cat and filter_text.is_empty():
				item_list.add_item("— %s —" % cat)
				item_list.set_item_disabled(item_list.item_count - 1, true)
				last_cat = cat
			var star := "★ " if _favorites and _favorites.is_condition_favorite(str(item.get("id", ""))) else ""
			var icon := FKPickerIcons.for_category(cat)
			item_list.add_item(star + icon + str(item["name"]))
			var index = item_list.item_count - 1
			item_list.set_item_metadata(index, item["metadata"])
	
	if item_list.item_count == 0:
		if filter_text.is_empty():
			item_list.add_item("No conditions available for this node type")
		else:
			item_list.add_item("No conditions found")
		item_list.set_item_disabled(0, true)
	elif not filter_text.is_empty() and item_list.item_count > 0 and not item_list.is_item_disabled(0):
		item_list.select(0)
		_on_item_selected(0)

func _on_search_text_changed(new_text: String) -> void:
	_update_list(new_text)

func _is_node_compatible(node_class: String, supported_types: Array) -> bool:
	return FKProviderCompat.is_node_compatible(node_class, supported_types)

func _on_item_activated(index: int) -> void:
	"""Handle condition selection."""
	if item_list.is_item_disabled(index):
		return
	
	var metadata = item_list.get_item_metadata(index)
	var condition_id = metadata["id"]
	var inputs = metadata["inputs"]
	
	# Find condition name for recent items
	var condition_name = ""
	for condition in available_conditions:
		if condition.get_id() == condition_id:
			condition_name = condition.get_name()
			break
	
	print("[FKSelectConditionModal]: Condition selected: ", condition_id, " for node: ", selected_node_path)
	_recent_items_manager.add_recent_condition(condition_id, condition_name, selected_node_class)
	_modal_signals.condition_selected.emit(selected_node_path, condition_id, inputs)
	hide()

func _on_item_selected(index: int) -> void:
	"""Update description when item is selected."""
	if item_list.is_item_disabled(index):
		description_label.text = ""
		return
	
	var metadata = item_list.get_item_metadata(index)
	var condition_id = metadata["id"]
	
	# Find the condition and get description
	for condition in available_conditions:
		if condition.get_id() == condition_id:
			description_label.text = condition.get_description()
			break

func _on_popup_hide() -> void:
	search_box.clear()

func _populate_recent_list() -> void:
	"""Populate favorites + recent conditions list."""
	if not recent_item_list or not _recent_items_manager:
		return
	
	recent_item_list.clear()
	
	if _favorites and not _favorites.favorite_conditions.is_empty():
		recent_item_list.add_item("— Favorites —")
		recent_item_list.set_item_disabled(recent_item_list.item_count - 1, true)
		for fav in _favorites.favorite_conditions:
			recent_item_list.add_item("★ " + str(fav.get("name", fav.get("id", ""))))
			recent_item_list.set_item_metadata(recent_item_list.item_count - 1, fav)
	
	var recent_for_type = []
	for recent_condition in _recent_items_manager.recent_conditions:
		if recent_condition["node_class"] == selected_node_class:
			recent_for_type.append(recent_condition)
	
	if recent_for_type.is_empty() and (_favorites == null or _favorites.favorite_conditions.is_empty()):
		recent_item_list.add_item("(No recent / favorites)")
		recent_item_list.set_item_disabled(0, true)
		return
	
	if not recent_for_type.is_empty():
		recent_item_list.add_item("— Recent —")
		recent_item_list.set_item_disabled(recent_item_list.item_count - 1, true)
		for recent_condition in recent_for_type:
			recent_item_list.add_item(recent_condition["name"])
			var index = recent_item_list.item_count - 1
			recent_item_list.set_item_metadata(index, recent_condition)

func _on_recent_item_activated(index: int) -> void:
	"""Handle selection from recent items."""
	if recent_item_list.is_item_disabled(index):
		return
	
	var recent_condition = recent_item_list.get_item_metadata(index)
	if recent_condition == null or not (recent_condition is Dictionary):
		return
	var condition_id = recent_condition["id"]
	
	# Find the condition to get its inputs
	var condition_inputs: Array = []
	for condition in available_conditions:
		if condition.get_id() == condition_id:
			condition_inputs = condition.get_inputs()
			break
	
	print("[FKSelectConditionModal]: Recent condition selected: ", condition_id, " for node: ", selected_node_path)
	_modal_signals.condition_selected.emit(selected_node_path, condition_id, condition_inputs)
	hide()
