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
var compatible_only: bool = true
var _compat_toggle: CheckButton

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

func _load_available_events() -> void:
	"""Load events from FKRegistry (no per-modal disk scan)."""
	available_events.clear()
	if editor_globals and editor_globals.registry:
		var reg = editor_globals.registry
		# Ensure providers exist (plugin should have loaded; belt-and-suspenders).
		if reg.event_providers.is_empty() and reg.has_method("load_providers"):
			reg.load_providers()
		available_events = FKProviderCompat.providers_from_registry(reg, "event")
	print("[FKSelectEventModal]: Loaded ", available_events.size(), " events for class=", selected_node_class)

func populate_events(node_path: String, node_class: String) -> void:
	"""Populate the list with events compatible with the selected node."""
	selected_node_path = node_path
	selected_node_class = node_class
	if _favorites == null:
		_favorites = FavoritesScript.new()
	if _recent_items_manager == null:
		_recent_items_manager = FKRecentItemsManagerUi.new()
	_ensure_compat_toggle()
	_load_available_events()
	if not item_list:
		return
	if description_label:
		description_label.text = "Events for %s · %s" % [node_class, node_path]
	var fav_cb := func(id: String) -> bool:
		return _favorites != null and _favorites.is_event_favorite(id)
	_all_items_cache = FKProviderPickerCore.build_items(
		editor_globals.registry if editor_globals else null,
		"event",
		node_class,
		compatible_only,
		fav_cb
	)
	_update_list()
	_populate_recent_list()
	if search_box:
		search_box.clear()
		search_box.grab_focus()
	print("[FKSelectEventModal]: Showing ", _all_items_cache.size(), " events for ", node_class, " @ ", node_path)

func _ensure_compat_toggle() -> void:
	if search_box == null:
		return
	var host := search_box.get_parent() as Control
	if host == null:
		return
	_compat_toggle = FKProviderPickerCore.ensure_mode_toggle(host, compatible_only, func(on: bool):
		compatible_only = on
		if not selected_node_class.is_empty():
			populate_events(selected_node_path, selected_node_class)
	)

func _category_counts() -> Dictionary:
	var counts: Dictionary = {}
	for item in _all_items_cache:
		var cat := str(item.get("category", "General"))
		counts[cat] = int(counts.get(cat, 0)) + 1
	return counts

func _update_list(filter_text: String = "") -> void:
	var fav_cb := func(id: String) -> bool:
		return _favorites != null and _favorites.is_event_favorite(id)
	FKProviderPickerCore.fill_item_list(
		item_list, _all_items_cache, filter_text, true, fav_cb, "id"
	)
	if not filter_text.is_empty() and item_list.item_count > 0 and not item_list.is_item_disabled(0):
		item_list.select(0)
		_on_item_selected(0)

func _on_search_text_changed(new_text: String) -> void:
	_update_list(new_text)

func _is_node_compatible(node_class: String, supported_types: Array) -> bool:
	return FKProviderCompat.is_node_compatible(node_class, supported_types)

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
		elif event.button_index == MOUSE_BUTTON_LEFT:
			# Single click confirms (same as Select Node).
			var idx2 := item_list.get_item_at_position(event.position, true)
			if idx2 >= 0 and not item_list.is_item_disabled(idx2):
				call_deferred("_confirm_event_index", idx2)
				get_viewport().set_input_as_handled()

func _on_item_activated(index: int) -> void:
	_confirm_event_index(index)

func _confirm_event_index(index: int) -> void:
	if index < 0 or index >= item_list.item_count:
		return
	if item_list.is_item_disabled(index):
		return
	var event_id = item_list.get_item_metadata(index)
	if event_id == null:
		return
	var event_inputs: Array = []
	var event_name = ""
	for event in available_events:
		if event and event.has_method("get_id") and str(event.get_id()) == str(event_id):
			if event.has_method("get_inputs"):
				event_inputs = event.get_inputs()
			if event.has_method("get_name"):
				event_name = event.get_name()
			break
	print("[FKSelectEventModal]: Event selected: ", event_id, " for node: ", selected_node_path)
	if _recent_items_manager:
		_recent_items_manager.add_recent_event(str(event_id), event_name, selected_node_class)
	_modal_signals.event_selected.emit(selected_node_path, str(event_id), event_inputs)
	hide()

func _on_item_selected(index: int) -> void:
	"""Update description when item is selected."""
	if item_list.is_item_disabled(index):
		if description_label:
			description_label.text = ""
		return
	var event_id = item_list.get_item_metadata(index)
	if event_id == null:
		return
	for event in available_events:
		if event and event.has_method("get_id") and str(event.get_id()) == str(event_id):
			if description_label and event.has_method("get_description"):
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
