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
## Bottom-panel tab button returned by add_control_to_bottom_panel.
var _bottom_panel_button: Button = null

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
	_register_bottom_panel()
	_create_and_add_custom_inspector()
	_prep_export_plugin()
	_prep_debugger_plugin()
	print("[FlowKit]: Plugin loaded (bottom panel)")

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
	# Assign globals before legitimization (submodules need FKEditorGlobals).
	editor.legitimize()
	# Bottom panel hosts size children via container flags — not main-screen anchors.
	editor.set_anchors_preset(Control.PRESET_TOP_LEFT)
	editor.anchor_right = 0.0
	editor.anchor_bottom = 0.0
	editor.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	editor.size_flags_vertical = Control.SIZE_EXPAND_FILL
	editor.custom_minimum_size = Vector2(400, 320)

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
	_base_popup.add_item("Show FlowKit Panel", MENU_ITEM_SHOW_PANEL)
	_base_popup.id_pressed.connect(_on_base_popup_id_pressed)
	add_tool_submenu_item("FlowKit", _base_popup)

var _base_popup: PopupMenu

func _on_base_popup_id_pressed(id: int):
	if id == MENU_ITEM_SETTINGS:
		settings_window.popup_centered()
	elif id == MENU_ITEM_SHOW_PANEL:
		_show_flowkit_panel()

const MENU_ITEM_SETTINGS := 0
const MENU_ITEM_SHOW_PANEL := 1

func _add_runtime_autoloads():
	add_autoload_singleton(
		"FlowKitSystem",
		"res://addons/flowkit/runtime/flowkit_system.gd"
	)
	add_autoload_singleton(
		"FlowKit",
		"res://addons/flowkit/runtime/flowkit_engine.gd"
	)

## Event sheet lives in the bottom panel (Debugger / Output style).
## Main-screen host does not size plugin children reliably for scrollable UIs.
func _register_bottom_panel() -> void:
	if editor == null:
		return
	_bottom_panel_button = add_control_to_bottom_panel(editor, "FlowKit")
	if editor.has_method("_configure_scroll_layout"):
		editor._configure_scroll_layout()
	if editor.has_method("_on_host_panel_ready"):
		editor.call_deferred("_on_host_panel_ready")

func _show_flowkit_panel() -> void:
	if editor == null:
		return
	make_bottom_panel_item_visible(editor)

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

	if editor:
		remove_control_from_bottom_panel(editor)
		editor.queue_free()
		editor = null
	_bottom_panel_button = null

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

## No main-screen tab — sheet editor is a bottom panel item.
func _has_main_screen() -> bool:
	return false

func _get_plugin_name() -> String:
	return "FlowKit"

func _get_plugin_icon() -> Texture2D:
	return preload("res://addons/flowkit/assets/icon.svg")
