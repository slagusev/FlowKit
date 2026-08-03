@tool
extends EditorPlugin

var action_registry: FKRegistry = FKRegistry.new()
var generator: FKGenerator = null
var inspector_plugin
var export_plugin
var debugger_plugin: FKEditorDebuggerPlugin
var editor: FKMainEditor = null
var editor_globals: FKEditorGlobals = FKEditorGlobals.new()
var editor_interface: EditorInterface

## Right dock: Sheet Variables / Subsheets (Inspector-style).
var _meta_dock_host: Control = null
var _sheet_meta_panel: FKSheetMetaPanel = null

func _enable_plugin() -> void:
	pass

func _disable_plugin() -> void:
	pass

func _enter_tree() -> void:
	_prep_editor_globals()
	_prep_main_editor()
	_prep_settings_window()
	_prep_tool_submenu_entries()
	_add_runtime_autoloads()
	_register_main_screen()
	_register_sheet_meta_dock()
	_create_and_add_custom_inspector()
	_prep_export_plugin()
	_prep_debugger_plugin()
	print("[FlowKit]: Plugin loaded (main screen + Sheet dock)")

func _prep_debugger_plugin() -> void:
	debugger_plugin = FKEditorDebuggerPlugin.new()
	debugger_plugin.globals = editor_globals
	add_debugger_plugin(debugger_plugin)

func _prep_editor_globals():
	action_registry = FKRegistry.new()
	action_registry.load_providers()
	editor_interface = get_editor_interface()
	generator = FKGenerator.new(editor_interface)
	editor_globals = FKEditorGlobals.new()
	editor_globals.registry = action_registry
	editor_globals.editor_interface = editor_interface
	editor_globals.generator = generator

func _prep_main_editor():
	const path := FKEditorGlobals.MAIN_EDITOR_SCENE_PATH
	var editor_scene: PackedScene = preload(path)
	editor = editor_scene.instantiate()
	editor.editor_globals = editor_globals
	# Globals must be set before legitimization.
	editor.legitimize()

func _prep_settings_window():
	const scene_path := FKEditorGlobals.SETTINGS_WINDOW_SCENE_PATH
	var window_scene: PackedScene = preload(scene_path)
	settings_window = window_scene.instantiate() as FKSettingsWindow
	settings_window.visible = false
	settings_window.globals = editor_globals
	editor_globals.base_control.add_child(settings_window)
	settings_window._legitimize()

var settings_window: FKSettingsWindow

func _prep_tool_submenu_entries():
	_base_popup = PopupMenu.new()
	_base_popup.add_item("Settings", MENU_ITEM_SETTINGS)
	_base_popup.add_separator()
	_base_popup.add_item("Reload Providers (fix empty lists)", MENU_ITEM_RELOAD_PROVIDERS)
	_base_popup.add_item("Generate Providers (MAY BE UNSTABLE)", MENU_ITEM_GENERATE_PROVIDERS)
	_base_popup.add_item("Generate Provider Manifest (export)", MENU_ITEM_GENERATE_MANIFEST)
	_base_popup.add_separator()
	_base_popup.add_item("Provider Browser…", MENU_ITEM_PROVIDER_BROWSER)
	_base_popup.add_item("Command Palette (Ctrl+K)", MENU_ITEM_COMMAND_PALETTE)
	_base_popup.add_separator()
	_base_popup.add_item("Show FlowKit Main Tab", MENU_ITEM_SHOW_MAIN)
	_base_popup.id_pressed.connect(_on_base_popup_id_pressed)
	add_tool_submenu_item("FlowKit", _base_popup)

var _base_popup: PopupMenu

func _on_base_popup_id_pressed(id: int):
	match id:
		MENU_ITEM_SETTINGS:
			if settings_window:
				settings_window.popup_centered()
		MENU_ITEM_RELOAD_PROVIDERS:
			_reload_providers()
		MENU_ITEM_GENERATE_PROVIDERS:
			if editor and editor.has_method("_on_generate_providers"):
				editor._on_generate_providers()
		MENU_ITEM_GENERATE_MANIFEST:
			if editor and editor.has_method("_on_generate_manifest"):
				editor._on_generate_manifest()
		MENU_ITEM_PROVIDER_BROWSER:
			if editor and editor.has_method("_open_provider_browser"):
				get_editor_interface().set_main_screen_editor("FlowKit")
				editor._open_provider_browser()
		MENU_ITEM_COMMAND_PALETTE:
			if editor and editor.has_method("_open_command_palette"):
				get_editor_interface().set_main_screen_editor("FlowKit")
				editor._open_command_palette()
		MENU_ITEM_SHOW_MAIN:
			# Focus main-screen plugin tab
			get_editor_interface().set_main_screen_editor("FlowKit")

const MENU_ITEM_SETTINGS := 0
const MENU_ITEM_RELOAD_PROVIDERS := 1
const MENU_ITEM_GENERATE_PROVIDERS := 2
const MENU_ITEM_GENERATE_MANIFEST := 3
const MENU_ITEM_SHOW_MAIN := 4
const MENU_ITEM_PROVIDER_BROWSER := 5
const MENU_ITEM_COMMAND_PALETTE := 6

func _reload_providers() -> void:
	if action_registry and action_registry.has_method("load_providers"):
		action_registry.load_providers()
		print("[FlowKit]: Providers reloaded — actions=", action_registry.action_providers.size(),
			" conditions=", action_registry.condition_providers.size(),
			" events=", action_registry.event_providers.size())
		# Also mirror onto globals (same instance usually).
		if editor_globals:
			editor_globals.registry = action_registry

func _add_runtime_autoloads():
	add_autoload_singleton(
		"FlowKitSystem",
		"res://addons/flowkit/runtime/flowkit_system.gd"
	)
	add_autoload_singleton(
		"FlowKit",
		"res://addons/flowkit/runtime/flowkit_engine.gd"
	)

## Event sheet workspace — top main-screen tab next to 2D / 3D / Script / Game.
func _register_main_screen() -> void:
	var main_screen = editor_interface.get_editor_main_screen()
	main_screen.add_child(editor)
	editor.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	editor.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	editor.size_flags_vertical = Control.SIZE_EXPAND_FILL
	if editor.has_method("_configure_scroll_layout"):
		editor._configure_scroll_layout()
	# Hide until user opens the FlowKit main tab.
	_make_visible(false)

## Sheet Variables / Subsheets — right dock (Inspector / Node / Groups style).
func _register_sheet_meta_dock() -> void:
	_meta_dock_host = MarginContainer.new()
	_meta_dock_host.name = "FlowKitSheet"
	_meta_dock_host.custom_minimum_size = Vector2(260, 0)
	_meta_dock_host.add_theme_constant_override("margin_left", 4)
	_meta_dock_host.add_theme_constant_override("margin_right", 4)
	_meta_dock_host.add_theme_constant_override("margin_top", 4)
	_meta_dock_host.add_theme_constant_override("margin_bottom", 4)

	var scroll := ScrollContainer.new()
	scroll.name = "MetaScroll"
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.clip_contents = true
	_meta_dock_host.add_child(scroll)

	_sheet_meta_panel = FKSheetMetaPanel.new()
	_sheet_meta_panel.name = "SheetMetaPanel"
	# Dock scroll: width fills, height grows with content (enables vertical scroll).
	_sheet_meta_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_sheet_meta_panel.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	_sheet_meta_panel.custom_minimum_size = Vector2(240, 0)
	_sheet_meta_panel.setup(editor_globals)
	scroll.add_child(_sheet_meta_panel)

	add_control_to_dock(DOCK_SLOT_RIGHT_UL, _meta_dock_host)
	# Wire to main editor (save dirty, subsheet workflows).
	if editor and editor.has_method("bind_sheet_meta_panel"):
		editor.bind_sheet_meta_panel(_sheet_meta_panel)

func _create_and_add_custom_inspector():
	inspector_plugin = FKEditorInspectorPlugin.new()
	inspector_plugin.set_registry(action_registry)
	inspector_plugin.set_editor_interface(editor_interface)
	add_inspector_plugin(inspector_plugin)

func _prep_export_plugin():
	export_plugin = FKExportPlugin.new()
	export_plugin.set_generator(generator)
	add_export_plugin(export_plugin)

func _exit_tree() -> void:
	remove_tool_menu_item("FlowKit")
	if _base_popup and is_instance_valid(_base_popup) and _base_popup.id_pressed.is_connected(_on_base_popup_id_pressed):
		_base_popup.id_pressed.disconnect(_on_base_popup_id_pressed)
	action_registry.free()
	remove_autoload_singleton("FlowKitSystem")
	remove_autoload_singleton("FlowKit")

	if _meta_dock_host and is_instance_valid(_meta_dock_host):
		remove_control_from_docks(_meta_dock_host)
		_meta_dock_host.queue_free()
		_meta_dock_host = null
		_sheet_meta_panel = null

	if editor and is_instance_valid(editor):
		editor.queue_free()
		editor = null

	if inspector_plugin:
		remove_inspector_plugin(inspector_plugin)
		inspector_plugin = null

	if export_plugin:
		remove_export_plugin(export_plugin)
		export_plugin = null

	if debugger_plugin:
		remove_debugger_plugin(debugger_plugin)
		debugger_plugin = null

	if settings_window and is_instance_valid(settings_window):
		settings_window.queue_free()
		settings_window = null

func _has_main_screen() -> bool:
	return true

func _make_visible(visible: bool) -> void:
	if editor == null:
		return
	editor.visible = visible
	if visible:
		# Main-screen host: force full-rect after tab select.
		_fit_main_editor()
		if editor.is_inside_tree():
			editor.call_deferred("_on_main_screen_shown")

func _fit_main_editor() -> void:
	if editor == null or not is_instance_valid(editor):
		return
	var parent_ctrl := editor.get_parent() as Control
	editor.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	editor.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	editor.size_flags_vertical = Control.SIZE_EXPAND_FILL
	editor.position = Vector2.ZERO
	if parent_ctrl and parent_ctrl.size.x > 1.0 and parent_ctrl.size.y > 1.0:
		editor.size = parent_ctrl.size
	if editor.has_method("_fit_to_parent"):
		editor._fit_to_parent()
	if editor.has_method("_configure_scroll_layout"):
		editor._configure_scroll_layout()

func _get_plugin_name() -> String:
	return "FlowKit"

func _get_plugin_icon() -> Texture2D:
	return preload("res://addons/flowkit/assets/icon.svg")
