@tool
extends FKModalWindow
class_name FKSelectEventModal

var selected_node_path: String = ""
var selected_node_class: String = ""
var available_events: Array = []

@export_category("UI")
@export var search_box: LineEdit 
@export var item_list: ItemList 
@export var description_label: Label 
@export var recent_item_list: ItemList 
@export var desc_panel: Panel

@export_category("Styling")
@export var desc_panel_style: StyleBoxFlat

const FavoritesScript = preload("res://addons/flowkit/editor/modals/favorites_manager.gd")

var _all_items_cache: Array = []
var _favorites = null

func _enter_tree() -> void:
	super._enter_tree()
	
	if is_editor_preview or is_fully_legit:
		return
		
	_recent_items_manager = FKRecentItemsManagerUi.new()
	_favorites = FavoritesScript.new()
	_load_available_events()

var _recent_items_manager: Variant = null

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
		
func _apply_styling():
	desc_panel.add_theme_stylebox_override("panel", desc_panel_style)
		
func _toggle_subs(on: bool):
	if on and not _is_subbed:
		search_box.text_changed.connect(_on_search_text_changed)
		item_list.item_activated.connect(_on_item_activated)
		item_list.item_selected.connect(_on_item_selected)
		item_list.gui_input.connect(_on_item_list_gui_input)
		recent_item_list.item_activated.connect(_on_recent_item_activated)
	elif _is_subbed and !on:
		search_box.text_changed.disconnect(_on_search_text_changed)
		item_list.item_activated.disconnect(_on_item_activated)
		item_list.item_selected.disconnect(_on_item_selected)
		if item_list.gui_input.is_connected(_on_item_list_gui_input):
			item_list.gui_input.disconnect(_on_item_list_gui_input)
		recent_item_list.item_activated.disconnect(_on_recent_item_activated)
	else:
		return
		
	_is_subbed = on

func _on_item_list_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_RIGHT or (event.button_index == MOUSE_BUTTON_LEFT and event.ctrl_pressed):
			var idx := item_list.get_item_at_position(event.position, true)
			if idx < 0:
				return
			var eid = item_list.get_item_metadata(idx)
			if eid == null:
				return
			var ename := item_list.get_item_text(idx).replace("★ ", "")
			if _favorites:
				_favorites.toggle_event(str(eid), ename)
				_update_list(search_box.text if search_box else "")
				get_viewport().set_input_as_handled()
	
func _load_available_events() -> void:
	"""Load events from FKRegistry (no per-modal disk scan)."""
	available_events.clear()
	if editor_globals and editor_globals.registry:
		available_events = FKProviderCompat.providers_from_registry(editor_globals.registry, "event")
	print("[FKSelectEventModal]: Loaded ", available_events.size(), " events (registry)")

func populate_events(node_path: String, node_class: String) -> void:
	"""Populate the list with events compatible with the selected node."""
	selected_node_path = node_path
	selected_node_class = node_class
	_load_available_events()
	
	if not item_list:
		return
	
	_all_items_cache.clear()
	description_label.text = ""
	
	# Filter events that support this node type
	for event in available_events:
		# Check if this is the new FKEvent pattern or old FKEventProvider pattern
		if event.has_method("get_id"):
			# New FKEvent pattern
			var supported_types = event.get_supported_types()
			if _is_node_compatible(node_class, supported_types):
				var event_name = event.get_name()
				var event_id = event.get_id()
				var event_desc := ""
				if event.has_method("get_description"):
					event_desc = str(event.get_description())
				
				var cat := "General"
				if supported_types.size() > 0:
					cat = str(supported_types[0])
				_all_items_cache.append({
					"name": event_name,
					"id": event_id,
					"description": event_desc,
					"category": cat,
					"metadata": event_id
				})
		elif event.has_method("get_events_for"):
			# Old FKEventProvider pattern
			var supported_types = event.get_supported_types()
			if _is_node_compatible(node_class, supported_types):
				var events_list = event.get_events_for(null)
				for event_data in events_list:
					_all_items_cache.append({
						"name": event_data["name"],
						"id": event_data["id"],
						"description": event_data.get("description", ""),
						"category": str(supported_types[0]) if supported_types.size() > 0 else "General",
						"metadata": event_data["id"]
					})
	
	_all_items_cache.sort_custom(func(a, b):
		var af: bool = _favorites != null and _favorites.is_event_favorite(str(a.get("id", "")))
		var bf: bool = _favorites != null and _favorites.is_event_favorite(str(b.get("id", "")))
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

func _category_counts() -> Dictionary:
	var counts: Dictionary = {}
	for item in _all_items_cache:
		var cat := str(item.get("category", "General"))
		counts[cat] = int(counts.get(cat, 0)) + 1
	return counts

func _update_list(filter_text: String = "") -> void:
	item_list.clear()
	var filter_lower = filter_text.to_lower().strip_edges()
	var last_cat := ""
	var counts := _category_counts()
	
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
				var n: int = int(counts.get(cat, 0))
				item_list.add_item("— %s (%d) —" % [cat, n])
				item_list.set_item_disabled(item_list.item_count - 1, true)
				last_cat = cat
			var star := "★ " if _favorites and _favorites.is_event_favorite(str(item.get("id", ""))) else ""
			var icon := FKPickerIcons.for_category(cat)
			item_list.add_item(star + icon + str(item["name"]))
			var index = item_list.item_count - 1
			item_list.set_item_metadata(index, item["metadata"])
	
	if item_list.item_count == 0:
		if filter_text.is_empty():
			item_list.add_item("No events available for this node type")
		else:
			item_list.add_item("No events found")
		item_list.set_item_disabled(0, true)
	elif not filter_text.is_empty() and item_list.item_count > 0 and not item_list.is_item_disabled(0):
		item_list.select(0)
		_on_item_selected(0)

func _on_search_text_changed(new_text: String) -> void:
	_update_list(new_text)

func _is_node_compatible(node_class: String, supported_types: Array) -> bool:
	return FKProviderCompat.is_node_compatible(node_class, supported_types)

func _on_item_activated(index: int) -> void:
	"""Handle event selection."""
	if item_list.is_item_disabled(index):
		return
	
	var event_id = item_list.get_item_metadata(index)
	
	# Find the event provider to get its inputs and name
	var event_inputs: Array = []
	var event_name = ""
	for event in available_events:
		if event.has_method("get_id") and event.get_id() == event_id:
			if event.has_method("get_inputs"):
				event_inputs = event.get_inputs()
			if event.has_method("get_name"):
				event_name = event.get_name()
			break
	
	print("[FKSelectEventModal]: Event selected: ", event_id, " for node: ", selected_node_path, " with inputs: ", event_inputs)
	_recent_items_manager.add_recent_event(event_id, event_name, selected_node_class)
	_modal_signals.event_selected.emit(selected_node_path, event_id, event_inputs)
	hide()

func _on_item_selected(index: int) -> void:
	"""Update description when item is selected."""
	if item_list.is_item_disabled(index):
		description_label.text = ""
		return
	
	var event_id = item_list.get_item_metadata(index)
	
	# Find the event and get description
	for event in available_events:
		if event.has_method("get_id") and event.get_id() == event_id:
			description_label.text = event.get_description()
			break

func _on_popup_hide() -> void:
	if search_box:
		search_box.clear()

func _populate_recent_list() -> void:
	"""Populate favorites + recent events list."""
	if not recent_item_list or not _recent_items_manager:
		return
	
	recent_item_list.clear()
	
	if _favorites and not _favorites.favorite_events.is_empty():
		recent_item_list.add_item("— Favorites —")
		recent_item_list.set_item_disabled(recent_item_list.item_count - 1, true)
		for fav in _favorites.favorite_events:
			recent_item_list.add_item("★ " + str(fav.get("name", fav.get("id", ""))))
			recent_item_list.set_item_metadata(recent_item_list.item_count - 1, fav)
	
	var recent_for_type = []
	for recent_event in _recent_items_manager.recent_events:
		if recent_event["node_class"] == selected_node_class:
			recent_for_type.append(recent_event)
	
	if recent_for_type.is_empty() and (_favorites == null or _favorites.favorite_events.is_empty()):
		recent_item_list.add_item("(No recent / favorites)")
		recent_item_list.set_item_disabled(0, true)
		return
	
	if not recent_for_type.is_empty():
		recent_item_list.add_item("— Recent —")
		recent_item_list.set_item_disabled(recent_item_list.item_count - 1, true)
		for recent_event in recent_for_type:
			recent_item_list.add_item(recent_event["name"])
			var index = recent_item_list.item_count - 1
			recent_item_list.set_item_metadata(index, recent_event)

func _on_recent_item_activated(index: int) -> void:
	"""Handle selection from recent items."""
	if recent_item_list.is_item_disabled(index):
		return
	
	var recent_event = recent_item_list.get_item_metadata(index)
	if recent_event == null or not (recent_event is Dictionary):
		return
	var event_id = recent_event["id"]
	
	# Find the event to get its inputs
	var event_inputs: Array = []
	for event in available_events:
		if event.has_method("get_id") and event.get_id() == event_id:
			if event.has_method("get_inputs"):
				event_inputs = event.get_inputs()
			break
	
	print("[FKSelectEventModal]: Recent event selected: ", event_id, " for node: ", \
	selected_node_path)
	_modal_signals.event_selected.emit(selected_node_path, event_id, event_inputs)
	hide()
