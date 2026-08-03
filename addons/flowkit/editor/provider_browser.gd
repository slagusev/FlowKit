@tool
extends Window
class_name FKProviderBrowser
## In-editor catalog of actions / events / conditions from the live registry (v3.14).

var registry: Variant = null
var _kind: OptionButton
var _search: LineEdit
var _list: ItemList
var _detail: RichTextLabel
var _items: Array = []
var _built: bool = false


func _ready() -> void:
	title = "FlowKit Provider Browser"
	size = Vector2i(720, 520)
	close_requested.connect(hide)
	_build()


func _build() -> void:
	if _built:
		return
	_built = true
	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.offset_left = 8
	root.offset_top = 8
	root.offset_right = -8
	root.offset_bottom = -8
	root.add_theme_constant_override("separation", 6)
	add_child(root)
	var top := HBoxContainer.new()
	root.add_child(top)
	_kind = OptionButton.new()
	_kind.add_item("Actions", 0)
	_kind.add_item("Events", 1)
	_kind.add_item("Conditions", 2)
	_kind.add_item("Behaviors", 3)
	_kind.item_selected.connect(func(_i): _rebuild_list())
	top.add_child(_kind)
	_search = LineEdit.new()
	_search.placeholder_text = "Search id / name / type…"
	_search.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_search.clear_button_enabled = true
	_search.text_changed.connect(func(_t): _rebuild_list())
	top.add_child(_search)
	var split := HSplitContainer.new()
	split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(split)
	_list = ItemList.new()
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_list.item_selected.connect(_on_select)
	split.add_child(_list)
	_detail = RichTextLabel.new()
	_detail.bbcode_enabled = true
	_detail.fit_content = false
	_detail.scroll_active = true
	_detail.custom_minimum_size = Vector2(280, 0)
	_detail.size_flags_vertical = Control.SIZE_EXPAND_FILL
	split.add_child(_detail)
	var foot := Label.new()
	foot.text = "Live registry · Tools → FlowKit → Reload Providers to refresh"
	foot.add_theme_font_size_override("font_size", 10)
	foot.add_theme_color_override("font_color", Color(0.6, 0.65, 0.7))
	root.add_child(foot)


func open_with_registry(reg: Variant) -> void:
	if not _built:
		_build()
	registry = reg
	if registry and registry.has_method("load_providers"):
		if registry.action_providers.is_empty():
			registry.load_providers()
	_rebuild_list()
	popup_centered()


func _kind_key() -> String:
	match _kind.selected if _kind else 0:
		1: return "event"
		2: return "condition"
		3: return "behavior"
		_: return "action"


func _rebuild_list() -> void:
	if _list == null:
		return
	_list.clear()
	_items.clear()
	if registry == null:
		if _detail:
			_detail.text = "No registry"
		return
	var kind := _kind_key()
	var providers: Array = FKProviderCompat.providers_from_registry(registry, kind)
	var q := _search.text.strip_edges().to_lower() if _search else ""
	for p in providers:
		if p == null or not p.has_method("get_id"):
			continue
		var id := str(p.get_id())
		var name := str(p.get_name()) if p.has_method("get_name") else id
		var types: Array = []
		if p.has_method("get_supported_types"):
			for t in p.get_supported_types():
				types.append(str(t))
		var desc := ""
		if p.has_method("get_description"):
			desc = str(p.get_description())
		var hay := (id + " " + name + " " + ",".join(types) + " " + desc).to_lower()
		if not q.is_empty() and q not in hay:
			continue
		_items.append({"id": id, "name": name, "types": types, "desc": desc, "kind": kind})
		_list.add_item("%s  ·  %s" % [id, name])
		_list.set_item_metadata(_list.item_count - 1, _items.size() - 1)
	if _detail:
		_detail.text = "[b]%d[/b] %s providers" % [_items.size(), kind]
	if _list.item_count > 0:
		_list.select(0)
		_on_select(0)


func _on_select(index: int) -> void:
	if index < 0 or index >= _list.item_count:
		return
	var mi = _list.get_item_metadata(index)
	var i := int(mi) if mi != null else index
	if i < 0 or i >= _items.size():
		return
	var it: Dictionary = _items[i]
	var types: PackedStringArray = PackedStringArray()
	for t in it.get("types", []):
		types.append(str(t))
	_detail.text = "[b]%s[/b]\n[color=#8af]%s[/color]\n\n[i]types:[/i] %s\n\n%s" % [
		str(it.get("id", "")),
		str(it.get("name", "")),
		", ".join(types),
		str(it.get("desc", ""))
	]
