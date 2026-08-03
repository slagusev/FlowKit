@tool
extends FKModalWindow
class_name FKSelectActionModal

var selected_node_path: String = ""
var selected_node_class: String = ""
var available_actions: Array = []

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
## When true, only providers matching the node class are listed.
var compatible_only: bool = true
var _compat_toggle: CheckButton

func _enter_tree() -> void:
	super._enter_tree()
	if is_editor_preview or is_fully_legit:
		return
		
	_recent_items_manager = FKRecentItemsManagerUi.new()
	_favorites = FavoritesScript.new()
	_load_available_actions()

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
	desc_panel.add_theme_stylebox_override("panel", desc_panel_style)
	
func _toggle_subs(should_sub: bool):
	if should_sub and not _is_subbed:
		search_box.text_changed.connect(_on_search_text_changed)
		search_box.text_submitted.connect(_on_search_submitted)
		item_list.item_activated.connect(_on_item_activated)
		item_list.item_selected.connect(_on_item_selected)
		item_list.gui_input.connect(_on_item_list_gui_input)
		recent_item_list.item_activated.connect(_on_recent_item_activated)

	elif _is_subbed and !should_sub:
		search_box.text_changed.disconnect(_on_search_text_changed)
		if search_box.text_submitted.is_connected(_on_search_submitted):
			search_box.text_submitted.disconnect(_on_search_submitted)
		item_list.item_activated.disconnect(_on_item_activated)
		item_list.item_selected.disconnect(_on_item_selected)
		if item_list.gui_input.is_connected(_on_item_list_gui_input):
			item_list.gui_input.disconnect(_on_item_list_gui_input)
		recent_item_list.item_activated.disconnect(_on_recent_item_activated)
		
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
			var aid: String = str(meta.get("id", ""))
			var aname := item_list.get_item_text(idx).replace("★ ", "").replace("☆ ", "")
			if _favorites and not aid.is_empty():
				_favorites.toggle_action(aid, aname)
				_update_list(search_box.text if search_box else "")
				get_viewport().set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_LEFT:
			var idx2 := item_list.get_item_at_position(event.position, true)
			if idx2 >= 0 and not item_list.is_item_disabled(idx2):
				call_deferred("_confirm_action_index", idx2)
				get_viewport().set_input_as_handled()

func _on_search_submitted(_text: String) -> void:
	if item_list.item_count == 0:
		return
	var selected := item_list.get_selected_items()
	var index := selected[0] if selected.size() > 0 else 0
	if not item_list.is_item_disabled(index):
		_confirm_action_index(index)

func _load_available_actions() -> void:
	available_actions.clear()
	if editor_globals and editor_globals.registry:
		var reg = editor_globals.registry
		if reg.action_providers.is_empty() and reg.has_method("load_providers"):
			reg.load_providers()
		available_actions = FKProviderCompat.providers_from_registry(reg, "action")
	print("[FKSelectActionModal]: Loaded ", available_actions.size(), " actions for class=", selected_node_class)

func populate_actions(node_path: String, node_class: String) -> void:
	"""Populate the list with actions compatible with the selected node."""
	selected_node_path = node_path
	selected_node_class = node_class
	if _favorites == null:
		_favorites = FavoritesScript.new()
	if _recent_items_manager == null:
		_recent_items_manager = FKRecentItemsManagerUi.new()
	_ensure_compat_toggle()
	_load_available_actions()
	if not item_list:
		return
	if description_label:
		description_label.text = "Actions for %s · %s" % [node_class, node_path]
	var fav_cb := func(id: String) -> bool:
		return _favorites != null and _favorites.is_action_favorite(id)
	_all_items_cache = FKProviderPickerCore.build_items(
		editor_globals.registry if editor_globals else null,
		"action",
		node_class,
		compatible_only,
		fav_cb
	)
	_update_list()
	_populate_recent_list()
	_focus_search()
	print("[FKSelectActionModal]: Showing ", _all_items_cache.size(), " actions for ", node_class, " @ ", node_path)

func _ensure_compat_toggle() -> void:
	if search_box == null:
		return
	var host := search_box.get_parent() as Control
	if host == null:
		return
	_compat_toggle = FKProviderPickerCore.ensure_mode_toggle(host, compatible_only, func(on: bool):
		compatible_only = on
		if not selected_node_class.is_empty():
			populate_actions(selected_node_path, selected_node_class)
	)

func _focus_search() -> void:
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
	var fav_cb := func(id: String) -> bool:
		return _favorites != null and _favorites.is_action_favorite(id)
	FKProviderPickerCore.fill_item_list(
		item_list, _all_items_cache, filter_text, true, fav_cb, "action_dict"
	)
	if item_list.item_count == 0 and filter_text.is_empty():
		item_list.add_item("Registry empty — Tools → FlowKit → Reload Providers")
		item_list.set_item_disabled(0, true)
	elif not filter_text.is_empty() and item_list.item_count > 0 and not item_list.is_item_disabled(0):
		item_list.select(0)
		_on_item_selected(0)

func _on_search_text_changed(new_text: String) -> void:
	_update_list(new_text)

func _is_node_compatible(node_class: String, supported_types: Array) -> bool:
	return FKProviderCompat.is_node_compatible(node_class, supported_types)

func _on_item_activated(index: int) -> void:
	_confirm_action_index(index)

func _confirm_action_index(index: int) -> void:
	if index < 0 or index >= item_list.item_count:
		return
	if item_list.is_item_disabled(index):
		return
	var metadata = item_list.get_item_metadata(index)
	if metadata == null or not (metadata is Dictionary):
		return
	var action_id = metadata.get("id", "")
	var inputs = metadata.get("inputs", [])
	var action_name = ""
	for action in available_actions:
		if action and action.has_method("get_id") and str(action.get_id()) == str(action_id):
			if action.has_method("get_name"):
				action_name = action.get_name()
			break
	print("[FKSelectActionModal]: Action selected: ", action_id, " for node: ", selected_node_path)
	if _recent_items_manager:
		_recent_items_manager.add_recent_action(str(action_id), action_name, selected_node_class)
	_modal_signals.action_selected.emit(selected_node_path, str(action_id), inputs)
	hide()

func _on_item_selected(index: int) -> void:
	"""Update description when item is selected."""
	if item_list.is_item_disabled(index):
		description_label.text = ""
		return
	
	var metadata = item_list.get_item_metadata(index)
	var action_id = metadata["id"]
	
	# Find the action and get description
	for action in available_actions:
		if action.get_id() == action_id:
			description_label.text = action.get_description()
			break

func _on_popup_hide() -> void:
	if search_box:
		search_box.clear()

func _populate_recent_list() -> void:
	"""Populate favorites + recent actions list."""
	if not recent_item_list or not _recent_items_manager:
		return
	
	recent_item_list.clear()
	
	# Favorites section
	if _favorites and not _favorites.favorite_actions.is_empty():
		recent_item_list.add_item("— Favorites —")
		recent_item_list.set_item_disabled(recent_item_list.item_count - 1, true)
		for fav in _favorites.favorite_actions:
			recent_item_list.add_item("★ " + str(fav.get("name", fav.get("id", ""))))
			var fi = recent_item_list.item_count - 1
			recent_item_list.set_item_metadata(fi, fav)
	
	# Filter recent actions for current node type
	var recent_for_type = []
	for recent_action in _recent_items_manager.recent_actions:
		if recent_action["node_class"] == selected_node_class:
			recent_for_type.append(recent_action)
	
	if recent_for_type.is_empty() and (_favorites == null or _favorites.favorite_actions.is_empty()):
		recent_item_list.add_item("(No recent / favorites)")
		recent_item_list.set_item_disabled(0, true)
		return
	
	if not recent_for_type.is_empty():
		recent_item_list.add_item("— Recent —")
		recent_item_list.set_item_disabled(recent_item_list.item_count - 1, true)
		for recent_action in recent_for_type:
			recent_item_list.add_item(recent_action["name"])
			var index = recent_item_list.item_count - 1
			recent_item_list.set_item_metadata(index, recent_action)

func _on_recent_item_activated(index: int) -> void:
	"""Handle selection from recent items."""
	if recent_item_list.is_item_disabled(index):
		return
	
	var recent_action = recent_item_list.get_item_metadata(index)
	var action_id = recent_action["id"]
	
	# Find the action to get its inputs
	var action_inputs: Array = []
	for action in available_actions:
		if action.get_id() == action_id:
			action_inputs = action.get_inputs()
			break
	
	print("[FKSelectActionModal]: Recent action selected: ", action_id, " for node: ", \
	selected_node_path)
	_modal_signals.action_selected.emit(selected_node_path, action_id, action_inputs)
	hide()
