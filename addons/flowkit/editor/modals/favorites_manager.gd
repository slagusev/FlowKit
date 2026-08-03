@tool
extends RefCounted
class_name FKFavoritesManager
## Starred actions / events / conditions for quick pick.

const CONFIG_PATH := "user://flowkit_favorites.cfg"
const MAX_FAVORITES := 40

var favorite_actions: Array = []  # {id, name}
var favorite_events: Array = []
var favorite_conditions: Array = []

func _init() -> void:
	load_from_config()

func is_action_favorite(action_id: String) -> bool:
	return _has_id(favorite_actions, action_id)

func toggle_action(action_id: String, action_name: String) -> bool:
	if _has_id(favorite_actions, action_id):
		_remove_id(favorite_actions, action_id)
		save_to_config()
		return false
	_add(favorite_actions, {"id": action_id, "name": action_name})
	save_to_config()
	return true

func is_event_favorite(event_id: String) -> bool:
	return _has_id(favorite_events, event_id)

func toggle_event(event_id: String, event_name: String) -> bool:
	if _has_id(favorite_events, event_id):
		_remove_id(favorite_events, event_id)
		save_to_config()
		return false
	_add(favorite_events, {"id": event_id, "name": event_name})
	save_to_config()
	return true

func is_condition_favorite(condition_id: String) -> bool:
	return _has_id(favorite_conditions, condition_id)

func toggle_condition(condition_id: String, condition_name: String) -> bool:
	if _has_id(favorite_conditions, condition_id):
		_remove_id(favorite_conditions, condition_id)
		save_to_config()
		return false
	_add(favorite_conditions, {"id": condition_id, "name": condition_name})
	save_to_config()
	return true

func _has_id(list: Array, id: String) -> bool:
	for item in list:
		if item is Dictionary and str(item.get("id", "")) == id:
			return true
	return false

func _remove_id(list: Array, id: String) -> void:
	for i in range(list.size() - 1, -1, -1):
		if list[i] is Dictionary and str(list[i].get("id", "")) == id:
			list.remove_at(i)

func _add(list: Array, item: Dictionary) -> void:
	_remove_id(list, str(item.get("id", "")))
	list.insert(0, item)
	while list.size() > MAX_FAVORITES:
		list.pop_back()

func save_to_config() -> void:
	var config := ConfigFile.new()
	_save_list(config, "actions", favorite_actions)
	_save_list(config, "events", favorite_events)
	_save_list(config, "conditions", favorite_conditions)
	config.save(CONFIG_PATH)

func _save_list(config: ConfigFile, section: String, list: Array) -> void:
	for i in range(list.size()):
		config.set_value(section, "item_%d" % i, list[i])

func load_from_config() -> void:
	var config := ConfigFile.new()
	if config.load(CONFIG_PATH) != OK:
		return
	favorite_actions = _load_list(config, "actions")
	favorite_events = _load_list(config, "events")
	favorite_conditions = _load_list(config, "conditions")

func _load_list(config: ConfigFile, section: String) -> Array:
	var out: Array = []
	if not config.has_section(section):
		return out
	for key in config.get_section_keys(section):
		out.append(config.get_value(section, key))
	return out
