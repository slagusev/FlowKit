extends RefCounted
class_name FKProviderPickerCore
## Shared list-building for event / action / condition pickers (v3.11).
## Supports Compatible-only vs All (incompatible dimmed) modes.


static func ensure_registry(registry: Variant) -> void:
	if registry == null:
		return
	if not registry.has_method("load_providers"):
		return
	var empty := false
	if "action_providers" in registry and registry.action_providers.is_empty():
		empty = true
	if "event_providers" in registry and registry.event_providers.is_empty():
		empty = true
	if empty:
		registry.load_providers()


## Build display items for a provider kind filtered by node class.
## Returns Array of Dictionary:
## { name, id, description, category, compatible, supported_types, inputs? }
static func build_items(
	registry: Variant,
	kind: String,
	node_class: String,
	compatible_only: bool = true,
	is_favorite: Callable = Callable()
) -> Array:
	ensure_registry(registry)
	var providers: Array = FKProviderCompat.providers_from_registry(registry, kind)
	var items: Array = []
	for p in providers:
		if p == null:
			continue
		if not p.has_method("get_id") or not p.has_method("get_name"):
			# Legacy multi-provider bags (rare)
			if p.has_method("get_events_for") and kind == "event":
				var st_legacy: Array = _types_of(p)
				var ok_leg := FKProviderCompat.is_node_compatible(node_class, st_legacy)
				if compatible_only and not ok_leg:
					continue
				for event_data in p.get_events_for(null):
					items.append({
						"name": str(event_data.get("name", "")),
						"id": str(event_data.get("id", "")),
						"description": str(event_data.get("description", "")),
						"category": str(st_legacy[0]) if st_legacy.size() > 0 else "General",
						"compatible": ok_leg,
						"supported_types": st_legacy,
						"inputs": []
					})
			continue
		var st: Array = _types_of(p)
		var ok := FKProviderCompat.is_node_compatible(node_class, st)
		if compatible_only and not ok:
			continue
		var pid := str(p.get_id())
		var pname := str(p.get_name())
		var pdesc := ""
		if p.has_method("get_description"):
			pdesc = str(p.get_description())
		var cat := "General"
		if st.size() > 0:
			cat = str(st[0])
		var inputs: Array = []
		if p.has_method("get_inputs"):
			inputs = p.get_inputs()
		items.append({
			"name": pname,
			"id": pid,
			"description": pdesc,
			"category": cat,
			"compatible": ok,
			"supported_types": st,
			"inputs": inputs
		})
	_sort_items(items, is_favorite)
	return items


static func _types_of(provider) -> Array:
	var out: Array = []
	if provider == null or not provider.has_method("get_supported_types"):
		return out
	for t in provider.get_supported_types():
		out.append(str(t))
	return out


static func _sort_items(items: Array, is_favorite: Callable) -> void:
	items.sort_custom(func(a, b):
		var af := false
		var bf := false
		if is_favorite.is_valid():
			af = bool(is_favorite.call(str(a.get("id", ""))))
			bf = bool(is_favorite.call(str(b.get("id", ""))))
		if af != bf:
			return af
		# Compatible first when showing All
		var ac := bool(a.get("compatible", true))
		var bc := bool(b.get("compatible", true))
		if ac != bc:
			return ac
		var ca := str(a.get("category", ""))
		var cb := str(b.get("category", ""))
		if ca != cb:
			return ca < cb
		return str(a.get("name", "")).to_lower() < str(b.get("name", "")).to_lower()
	)


static func category_counts(items: Array) -> Dictionary:
	var counts: Dictionary = {}
	for item in items:
		var cat := str(item.get("category", "General"))
		counts[cat] = int(counts.get(cat, 0)) + 1
	return counts


## Fill an ItemList from items + search filter. Returns list of metadata values set per row.
## metadata_mode: "id" | "action_dict" (id+inputs)
static func fill_item_list(
	item_list: ItemList,
	items: Array,
	filter_text: String = "",
	show_category_headers: bool = true,
	is_favorite: Callable = Callable(),
	metadata_mode: String = "id"
) -> void:
	if item_list == null:
		return
	item_list.clear()
	var filter_lower := filter_text.to_lower().strip_edges()
	var last_cat := ""
	var counts := category_counts(items)
	var any := false
	for item in items:
		var haystack := (
			str(item.get("name", "")) + " " +
			str(item.get("id", "")) + " " +
			str(item.get("category", "")) + " " +
			str(item.get("description", ""))
		).to_lower()
		if not filter_text.is_empty() and filter_lower not in haystack:
			continue
		var cat := str(item.get("category", "General"))
		if show_category_headers and filter_text.is_empty() and cat != last_cat:
			var n: int = int(counts.get(cat, 0))
			item_list.add_item("— %s (%d) —" % [cat, n])
			item_list.set_item_disabled(item_list.item_count - 1, true)
			last_cat = cat
		var star := ""
		if is_favorite.is_valid() and bool(is_favorite.call(str(item.get("id", "")))):
			star = "★ "
		var icon := ""
		var icon_script = load("res://addons/flowkit/editor/modals/picker_icons.gd")
		if icon_script and icon_script.has_method("for_category"):
			icon = str(icon_script.for_category(cat))
		var compat := bool(item.get("compatible", true))
		var label := star + icon + str(item.get("name", ""))
		if not compat:
			var types: PackedStringArray = PackedStringArray()
			for t in item.get("supported_types", []):
				types.append(str(t))
			label = "⊘ " + label + "  [" + ",".join(types) + "]"
		item_list.add_item(label)
		var index := item_list.item_count - 1
		if metadata_mode == "action_dict":
			item_list.set_item_metadata(index, {
				"id": str(item.get("id", "")),
				"inputs": item.get("inputs", [])
			})
		else:
			item_list.set_item_metadata(index, str(item.get("id", "")))
		if not compat:
			item_list.set_item_custom_fg_color(index, Color(0.55, 0.55, 0.55, 0.9))
		any = true
	if not any:
		item_list.add_item("No providers for this filter")
		item_list.set_item_disabled(0, true)
		item_list.add_item("Try: All mode · Reload Providers · other node type")
		item_list.set_item_disabled(1, true)


static func ensure_mode_toggle(parent: Control, initial_compatible_only: bool, on_changed: Callable) -> CheckButton:
	## Create or reuse a "Compatible only" checkbutton under parent.
	var existing := parent.get_node_or_null("CompatModeToggle") as CheckButton
	if existing:
		existing.button_pressed = initial_compatible_only
		return existing
	var cb := CheckButton.new()
	cb.name = "CompatModeToggle"
	cb.text = "Compatible only"
	cb.tooltip_text = "Off = show all providers (incompatible dimmed with ⊘)"
	cb.button_pressed = initial_compatible_only
	cb.toggled.connect(func(pressed: bool):
		if on_changed.is_valid():
			on_changed.call(pressed)
	)
	# Prefer insert after search box if present
	if parent is VBoxContainer or parent.get_child_count() > 0:
		parent.add_child(cb)
		if parent.get_child_count() > 1:
			parent.move_child(cb, mini(1, parent.get_child_count() - 1))
	else:
		parent.add_child(cb)
	return cb
