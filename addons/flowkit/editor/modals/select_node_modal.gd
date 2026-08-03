@tool
extends FKModalWindow
class_name FKSelectNodeModal

## "event" | "action" | "condition" | "any" — which providers unlock a node.
var _compat_kind: String = "any"

var available_events: Array = []
var available_actions: Array = []
var available_conditions: Array = []

@export var search_box: LineEdit
@export var item_list: ItemList
@export var recent_item_list: ItemList

var _all_items_cache: Array = []

func _enter_tree() -> void:
	super._enter_tree()
	if is_editor_preview:
		return
	_recent_items_manager = FKRecentItemsManagerUi.new()

var _recent_items_manager: Variant = null

func _toggle_subs(should_sub: bool):
	if should_sub and not _is_subbed:
		search_box.text_changed.connect(_on_search_text_changed)
		item_list.item_activated.connect(_on_item_activated)
		item_list.item_selected.connect(_on_item_selected)
		item_list.gui_input.connect(_on_item_list_gui_input)
		recent_item_list.item_activated.connect(_on_recent_item_activated)
		recent_item_list.item_selected.connect(_on_recent_item_selected)
	elif _is_subbed and not should_sub:
		search_box.text_changed.disconnect(_on_search_text_changed)
		item_list.item_activated.disconnect(_on_item_activated)
		item_list.item_selected.disconnect(_on_item_selected)
		if item_list.gui_input.is_connected(_on_item_list_gui_input):
			item_list.gui_input.disconnect(_on_item_list_gui_input)
		recent_item_list.item_activated.disconnect(_on_recent_item_activated)
		if recent_item_list.item_selected.is_connected(_on_recent_item_selected):
			recent_item_list.item_selected.disconnect(_on_recent_item_selected)
	else:
		return
	_is_subbed = should_sub

func _ready() -> void:
	if is_editor_preview:
		return
	_reload_providers()
	_populate_recent_list()

func _reload_providers() -> void:
	available_events.clear()
	available_actions.clear()
	available_conditions.clear()
	if editor_globals == null or editor_globals.registry == null:
		return
	var reg = editor_globals.registry
	available_events = FKProviderCompat.providers_from_registry(reg, "event")
	available_actions = FKProviderCompat.providers_from_registry(reg, "action")
	available_conditions = FKProviderCompat.providers_from_registry(reg, "condition")

func _populate_recent_list() -> void:
	if not _recent_items_manager or not recent_item_list:
		return
	recent_item_list.clear()
	if _recent_items_manager.recent_nodes.is_empty():
		recent_item_list.add_item("(No recent items)")
		recent_item_list.set_item_disabled(0, true)
		return
	for recent_node in _recent_items_manager.recent_nodes:
		var display_name = recent_node["path"]
		if recent_node["path"] == "System":
			display_name = "System"
		recent_item_list.add_item(display_name)
		var index = recent_item_list.item_count - 1
		recent_item_list.set_item_metadata(index, recent_node)

## kind: "event" | "action" | "condition" | "any" | pending_block_type from main editor
func populate_from_scene(scene_root: Node, kind: String = "any") -> void:
	if not item_list:
		return
	_compat_kind = _normalize_kind(kind)
	_reload_providers()
	_all_items_cache.clear()

	var system_icon = null
	if _base_control:
		system_icon = _base_control.get_theme_icon("Node", "EditorIcons")

	_all_items_cache.append({
		"display_name": "System",
		"metadata": "System",
		"icon": system_icon,
		"disabled": false,
		"indentation": 0,
		"path": "System"
	})

	if scene_root:
		_add_node_recursive(scene_root, scene_root, 0)

	_update_list()
	_populate_recent_list()

func _normalize_kind(kind: String) -> String:
	var k := kind.to_lower()
	if k.begins_with("event"):
		return "event"
	if k.begins_with("action") or k.begins_with("subsheet_action") or k.begins_with("branch_action"):
		return "action"
	if k.begins_with("condition") or k.begins_with("branch_condition") or k.begins_with("elseif"):
		return "condition"
	if k == "any" or k.is_empty():
		return "any"
	# Default: allow all (safer than greying everything out).
	return "any"

func _add_node_recursive(node: Node, scene_root: Node, depth: int) -> void:
	var node_name = node.name
	var node_class = node.get_class()
	var relative_path = scene_root.get_path_to(node)
	# Prefer allowing selection; only soft-disable when we *know* nothing matches.
	var selectable := _is_node_selectable(node_class)
	var icon = null
	if _base_control:
		icon = _base_control.get_theme_icon(node_class, "EditorIcons")

	_all_items_cache.append({
		"display_name": node_name,
		"metadata": str(relative_path),
		"icon": icon,
		"disabled": not selectable,
		"indentation": depth,
		"path": str(relative_path)
	})

	for child in node.get_children():
		_add_node_recursive(child, scene_root, depth + 1)

func _update_list(filter_text: String = "") -> void:
	item_list.clear()
	var filter_lower = filter_text.to_lower()

	for item in _all_items_cache:
		var match_search = filter_text.is_empty() or \
			filter_lower in item["path"].to_lower() or \
			filter_lower in item["display_name"].to_lower()
		if not match_search:
			continue

		var display_text: String = item["display_name"]
		if not filter_text.is_empty() and item["metadata"] != "System":
			display_text = item["path"]
		else:
			display_text = "  ".repeat(item["indentation"]) + display_text

		item_list.add_item(display_text)
		var index = item_list.item_count - 1
		item_list.set_item_metadata(index, item["metadata"])
		if item["icon"]:
			item_list.set_item_icon(index, item["icon"])
		if item["disabled"]:
			# Dim only — do not hard-disable (ItemList disabled blocks all selection).
			item_list.set_item_custom_fg_color(index, Color(0.55, 0.55, 0.55, 0.85))
		else:
			item_list.set_item_custom_fg_color(index, Color(1, 1, 1, 1))

func _on_search_text_changed(new_text: String) -> void:
	_update_list(new_text)

## True if this class has at least one matching provider for current kind.
## If provider lists are empty, return true so the UI is never a dead end.
func _is_node_selectable(node_class: String) -> bool:
	var lists: Array = _provider_lists_for_kind()
	var any_loaded := false
	for providers in lists:
		if providers.size() > 0:
			any_loaded = true
			break
	if not any_loaded:
		return true
	for providers in lists:
		for p in providers:
			if p == null or not p.has_method("get_supported_types"):
				continue
			var supported = p.get_supported_types()
			if FKProviderCompat.is_node_compatible(node_class, supported):
				return true
	return false

func _provider_lists_for_kind() -> Array:
	match _compat_kind:
		"event":
			return [available_events]
		"action":
			return [available_actions]
		"condition":
			return [available_conditions]
		_:
			return [available_events, available_actions, available_conditions]

func _on_item_list_gui_input(event: InputEvent) -> void:
	# Single left-click confirms (ItemList "selected" alone is easy to miss).
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var idx := item_list.get_item_at_position(event.position, true)
		if idx >= 0:
			# Defer so ItemList finishes its own selection first.
			call_deferred("_confirm_index", idx)
			get_viewport().set_input_as_handled()

func _on_item_activated(index: int) -> void:
	_confirm_index(index)

func _on_item_selected(_index: int) -> void:
	# Keyboard navigation: Enter still uses item_activated; mouse uses gui_input.
	pass

func _confirm_index(index: int) -> void:
	if index < 0 or index >= item_list.item_count:
		return
	# Soft-disabled items are still allowed (user may want any node).
	var node_path_str = item_list.get_item_metadata(index)
	if node_path_str == null:
		return
	_emit_node_selected(str(node_path_str))

func _emit_node_selected(node_path_str: String) -> void:
	if node_path_str == "System":
		print("[FKSelectNodeModal]: Node selected: System (System)")
		if _recent_items_manager:
			_recent_items_manager.add_recent_node("System", "System")
		_modal_signals.node_selected.emit("System", "System")
		hide()
		return

	var node = _get_node_from_path(node_path_str)
	if node == null:
		push_warning("[FKSelectNodeModal]: Node not found: %s" % node_path_str)
		return
	var node_class = node.get_class()
	print("[FKSelectNodeModal]: Node selected: ", node_path_str, " (", node_class, ")")
	if _recent_items_manager:
		_recent_items_manager.add_recent_node(node_path_str, node_class)
	_modal_signals.node_selected.emit(node_path_str, node_class)
	hide()

func _get_node_from_path(node_path_str: String) -> Node:
	var current_scene = _editor_interface.get_edited_scene_root()
	if not current_scene:
		return null
	if node_path_str == ".":
		return current_scene
	return current_scene.get_node_or_null(node_path_str)

func _on_popup_hide() -> void:
	if search_box:
		search_box.clear()

func _on_recent_item_activated(index: int) -> void:
	_confirm_recent_index(index)

func _on_recent_item_selected(index: int) -> void:
	pass

func _confirm_recent_index(index: int) -> void:
	if recent_item_list.is_item_disabled(index):
		return
	var recent_node = recent_item_list.get_item_metadata(index)
	if recent_node == null or not (recent_node is Dictionary):
		return
	var node_path_str = str(recent_node.get("path", ""))
	var node_class = str(recent_node.get("class", "Node"))
	if node_path_str.is_empty():
		return
	print("[FKSelectNodeModal]: Recent node selected: ", node_path_str, " (", node_class, ")")
	_modal_signals.node_selected.emit(node_path_str, node_class)
	hide()
