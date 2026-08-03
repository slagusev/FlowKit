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
	# Right-click or Ctrl+click toggles favorite on selected item
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

func _on_search_submitted(_text: String) -> void:
	# Enter in search selects the first (or currently selected) match
	if item_list.item_count == 0:
		return
	var selected := item_list.get_selected_items()
	var index := selected[0] if selected.size() > 0 else 0
	if not item_list.is_item_disabled(index):
		_on_item_activated(index)
	
func _load_available_actions() -> void:
	"""Load actions from FKRegistry (no per-modal disk scan)."""
	available_actions.clear()
	if editor_globals and editor_globals.registry:
		available_actions = FKProviderCompat.providers_from_registry(editor_globals.registry, "action")
	print("[FKSelectActionModal]: Loaded ", available_actions.size(), " actions (registry)")

func populate_actions(node_path: String, node_class: String) -> void:
	"""Populate the list with actions compatible with the selected node."""
	selected_node_path = node_path
	selected_node_class = node_class
	# Refresh from registry in case providers were regenerated
	_load_available_actions()
	
	if not item_list:
		return
	
	_all_items_cache.clear()
	description_label.text = ""
	
	# Filter actions that support this node type
	for action in available_actions:
		var supported_types = action.get_supported_types()
		if _is_node_compatible(node_class, supported_types):
			var action_name = action.get_name()
			var action_id = action.get_id()
			var action_desc := ""
			if action.has_method("get_description"):
				action_desc = str(action.get_description())
			var cat := "General"
			if supported_types.size() > 0:
				cat = str(supported_types[0])
			_all_items_cache.append({
				"name": action_name,
				"id": action_id,
				"description": action_desc,
				"category": cat,
				"metadata": {"id": action_id, "inputs": action.get_inputs()}
			})
	
	# Favorites first, then category, then alphabetical
	_all_items_cache.sort_custom(func(a, b):
		var af: bool = _favorites != null and _favorites.is_action_favorite(str(a.get("id", "")))
		var bf: bool = _favorites != null and _favorites.is_action_favorite(str(b.get("id", "")))
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
	_focus_search()

func _focus_search() -> void:
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
			var star := ""
			if _favorites and _favorites.is_action_favorite(str(item.get("id", ""))):
				star = "★ "
			var icon := FKPickerIcons.for_category(str(item.get("category", "General")))
			item_list.add_item(star + icon + str(item["name"]))
			var index = item_list.item_count - 1
			item_list.set_item_metadata(index, item["metadata"])
	
	if item_list.item_count == 0:
		if filter_text.is_empty():
			item_list.add_item("No actions available for this node type")
		else:
			item_list.add_item("No actions found")
		item_list.set_item_disabled(0, true)
	elif not filter_text.is_empty() and item_list.item_count > 0 and not item_list.is_item_disabled(0):
		# Auto-select first match so Enter confirms quickly
		item_list.select(0)
		_on_item_selected(0)

func _on_search_text_changed(new_text: String) -> void:
	_update_list(new_text)

func _is_node_compatible(node_class: String, supported_types: Array) -> bool:
	return FKProviderCompat.is_node_compatible(node_class, supported_types)

func _on_item_activated(index: int) -> void:
	"""Handle action selection."""
	if item_list.is_item_disabled(index):
		return
	
	var metadata = item_list.get_item_metadata(index)
	var action_id = metadata["id"]
	var inputs = metadata["inputs"]
	
	# Find action name for recent items
	var action_name = ""
	for action in available_actions:
		if action.get_id() == action_id:
			action_name = action.get_name()
			break
	
	print("[FKSelectActionModal]: Action selected: ", action_id, " for node: ", selected_node_path)
	_recent_items_manager.add_recent_action(action_id, action_name, selected_node_class)
	_modal_signals.action_selected.emit(selected_node_path, action_id, inputs)
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
