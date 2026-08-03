@tool
extends AcceptDialog
class_name FKCommandPalette
## Ctrl+K command palette for FlowKit main editor (v3.14).

signal command_chosen(command_id: String)

var _search: LineEdit
var _list: ItemList
var _commands: Array = []  # {id, label, keywords}
var _built: bool = false


func _ready() -> void:
	title = "FlowKit Commands"
	ok_button_text = "Run"
	dialog_hide_on_ok = true
	size = Vector2i(520, 420)
	_build()
	if not confirmed.is_connected(_on_confirmed):
		confirmed.connect(_on_confirmed)
	visibility_changed.connect(func():
		if visible and _search:
			_search.grab_focus()
			_search.select_all()
	)


func _build() -> void:
	if _built:
		return
	_built = true
	var root := VBoxContainer.new()
	root.name = "PaletteRoot"
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 6)
	add_child(root)
	_search = LineEdit.new()
	_search.placeholder_text = "Type a command… (new event, save, import merge, providers…)"
	_search.clear_button_enabled = true
	_search.text_changed.connect(_on_filter)
	_search.text_submitted.connect(func(_t): _on_confirmed())
	root.add_child(_search)
	_list = ItemList.new()
	_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_list.custom_minimum_size = Vector2(0, 300)
	_list.item_activated.connect(func(_i): _on_confirmed())
	root.add_child(_list)


func setup_default_commands() -> void:
	_commands = [
		{"id": "new_event", "label": "Add Event", "keywords": "new event add"},
		{"id": "save", "label": "Save Sheet", "keywords": "save sheet"},
		{"id": "export_json", "label": "Export Sheet JSON…", "keywords": "export json"},
		{"id": "import_json", "label": "Import Sheet JSON (replace)…", "keywords": "import json replace"},
		{"id": "import_json_merge", "label": "Import Sheet JSON (merge)…", "keywords": "import json merge append"},
		{"id": "bulk_retarget", "label": "Bulk Retarget selection…", "keywords": "retarget target node"},
		{"id": "mute", "label": "Mute selected", "keywords": "mute disable"},
		{"id": "unmute", "label": "Enable selected", "keywords": "enable unmute"},
		{"id": "undo", "label": "Undo", "keywords": "undo"},
		{"id": "redo", "label": "Redo", "keywords": "redo"},
		{"id": "hot_reload", "label": "Hot-reload sheet from disk", "keywords": "reload hot disk"},
		{"id": "reload_providers", "label": "Reload Providers", "keywords": "providers registry"},
		{"id": "provider_browser", "label": "Open Provider Browser", "keywords": "matrix providers browser catalog"},
		{"id": "template_ready", "label": "Template: On Ready Print", "keywords": "template ready"},
		{"id": "template_score", "label": "Template: Score on Key", "keywords": "template score"},
		{"id": "filter_focus", "label": "Focus sheet filter", "keywords": "filter search"},
	]
	if _list == null:
		_build()
	_on_filter("")


func open_palette() -> void:
	if not _built:
		_build()
	if _commands.is_empty():
		setup_default_commands()
	popup_centered()
	if _search:
		_search.clear()
		_on_filter("")
		_search.grab_focus()


func _on_filter(text: String) -> void:
	if _list == null:
		return
	_list.clear()
	var q := text.strip_edges().to_lower()
	for c in _commands:
		var hay := (str(c.get("label", "")) + " " + str(c.get("keywords", "")) + " " + str(c.get("id", ""))).to_lower()
		if q.is_empty() or q in hay:
			_list.add_item(str(c.get("label", c.get("id", ""))))
			_list.set_item_metadata(_list.item_count - 1, str(c.get("id", "")))
	if _list.item_count > 0:
		_list.select(0)


func _on_confirmed() -> void:
	if _list == null or _list.item_count == 0:
		return
	var sel := _list.get_selected_items()
	var idx := sel[0] if sel.size() > 0 else 0
	var cid := str(_list.get_item_metadata(idx))
	if not cid.is_empty():
		command_chosen.emit(cid)
