extends Node
class_name FKSystem

## The System object - a global singleton accessible in every scene
## Similar to Clickteam Fusion's System object

# Signals that can be used with events
signal on_ready_triggered
signal on_process_triggered

var _ready_fired: bool = false

# Delta value (updated each frame by FlowKitEngine)
var delta: float = 0.0

# Global variable storage
var variables: Dictionary = {}

# Node variable storage (per-node variables using metadata)
var node_variables: Dictionary = {}

# Sheet-local variables: sheet_uid (int as String key) -> { var_name: value }
var sheet_variables: Dictionary = {}

# Active sheet context (set by FlowKitEngine while evaluating a sheet).
var current_sheet_uid: int = 0
var current_sheet_vars: Dictionary = {}
## For Each: the node currently being iterated.
var current: Node = null
var current_node: Node = null  # alias

## Active Call Subsheet argument map (p_name in expressions). Cleared when subsheet ends.
var subsheet_params: Dictionary = {}
## Result of Pick Nodes (Array of Node).
var picked: Array = []
var picked_count: int = 0

# Named callables registered by Define Function / usable via Call Function.
# Key: function name (String) → Callable
var functions: Dictionary = {}

## Debug log (ring buffer) for the overlay / console.
const DEBUG_LOG_MAX := 80
var debug_enabled: bool = true
var debug_log: Array = []  # Array of {t, kind, msg}
## Last condition-fail explanation string for overlay.
var last_cond_fail: String = ""
## Step debugger (F8 toggle, F9 step).
var debug_step_mode: bool = false
var debug_step_waiting: bool = false
var debug_step_request_continue: bool = false
var debug_step_label: String = ""
## Highlight targets for editor / overlay while stepping.
var debug_active_block_id: String = ""
var debug_active_event_id: String = ""
var debug_active_action_id: String = ""
## Last subsheet return value (r_ / system.subsheet_return).
var subsheet_return: Variant = null
## Named pick families: name -> {group, class, filter}
var families: Dictionary = {}
## Simple profiler: action_id -> {count, total_us, last_us}
var profile_stats: Dictionary = {}

var global_signals: FKGlobalSignals = FKGlobalSignals.new()

func _ready() -> void:
	if not _ready_fired:
		_ready_fired = true
		on_ready_triggered.emit()

func _process(_delta: float) -> void:
	on_process_triggered.emit()

# Global print function
func print_message(message: String) -> void:
	print("[System]: %s" % message)

# Variable management
func set_var(name: String, value: Variant) -> void:
	variables[name] = value

func get_var(name: String, default: Variant = null) -> Variant:
	return variables.get(name, default)

func has_var(name: String) -> bool:
	return variables.has(name)

func clear_var(name: String) -> void:
	variables.erase(name)

func clear_all_vars() -> void:
	variables.clear()

# --- Named functions (Define Function / Call Function) ---------------------
func register_function(function_name: String, callable: Callable) -> void:
	if function_name.is_empty():
		push_warning("[FlowKitSystem] Cannot register function with empty name.")
		return
	if not callable.is_valid():
		push_warning("[FlowKitSystem] Cannot register invalid callable for '%s'." % function_name)
		return
	functions[function_name] = callable

func unregister_function(function_name: String) -> void:
	functions.erase(function_name)

func has_function(function_name: String) -> bool:
	return functions.has(function_name)

func call_function(function_name: String, args: Array = []) -> Variant:
	if not functions.has(function_name):
		push_warning("[FlowKitSystem] Function not found: '%s'" % function_name)
		return null
	var cb: Callable = functions[function_name]
	if not cb.is_valid():
		push_warning("[FlowKitSystem] Function '%s' has an invalid callable." % function_name)
		return null
	return cb.callv(args)

func clear_all_functions() -> void:
	functions.clear()

# --- Sheet-local variables -------------------------------------------------
func init_sheet_vars(sheet_uid: int, defaults: Dictionary) -> void:
	var key := str(sheet_uid)
	var bucket: Dictionary = {}
	for k in defaults.keys():
		bucket[k] = defaults[k]
	sheet_variables[key] = bucket
	if current_sheet_uid == sheet_uid:
		current_sheet_vars = bucket

func set_active_sheet(sheet_uid: int) -> void:
	current_sheet_uid = sheet_uid
	var key := str(sheet_uid)
	if sheet_variables.has(key):
		current_sheet_vars = sheet_variables[key]
	else:
		current_sheet_vars = {}

func set_sheet_var(var_name: String, value: Variant, sheet_uid: int = -1) -> void:
	var uid := sheet_uid if sheet_uid >= 0 else current_sheet_uid
	var key := str(uid)
	if not sheet_variables.has(key):
		sheet_variables[key] = {}
	sheet_variables[key][var_name] = value
	if uid == current_sheet_uid:
		current_sheet_vars = sheet_variables[key]

func get_sheet_var(var_name: String, default: Variant = null, sheet_uid: int = -1) -> Variant:
	var uid := sheet_uid if sheet_uid >= 0 else current_sheet_uid
	var key := str(uid)
	if sheet_variables.has(key) and sheet_variables[key].has(var_name):
		return sheet_variables[key][var_name]
	return default

func has_sheet_var(var_name: String, sheet_uid: int = -1) -> bool:
	var uid := sheet_uid if sheet_uid >= 0 else current_sheet_uid
	var key := str(uid)
	return sheet_variables.has(key) and sheet_variables[key].has(var_name)

func clear_sheet_vars(sheet_uid: int = -1) -> void:
	var uid := sheet_uid if sheet_uid >= 0 else current_sheet_uid
	sheet_variables.erase(str(uid))
	if uid == current_sheet_uid:
		current_sheet_vars = {}

func set_current_node(node: Node) -> void:
	current = node
	current_node = node

# --- Debug -----------------------------------------------------------------
func debug_push(kind: String, msg: String) -> void:
	if not debug_enabled:
		return
	debug_log.append({
		"t": Time.get_ticks_msec(),
		"kind": kind,
		"msg": msg
	})
	while debug_log.size() > DEBUG_LOG_MAX:
		debug_log.pop_front()

func debug_clear() -> void:
	debug_log.clear()

# Node variable management
func set_node_var(node: Node, var_name: String, value: Variant) -> void:
	if not node:
		push_error("Cannot set node variable: node is null")
		return
	
	var node_path: String = str(node.get_path())
	
	if not node_variables.has(node_path):
		node_variables[node_path] = {}
	
	node_variables[node_path][var_name] = value
	
	# Also store in node metadata for persistence
	if node.has_meta("flowkit_variables"):
		var meta_vars: Dictionary = node.get_meta("flowkit_variables")
		meta_vars[var_name] = value
		node.set_meta("flowkit_variables", meta_vars)
	else:
		node.set_meta("flowkit_variables", {var_name: value})

func get_node_var(node: Node, var_name: String, default: Variant = null) -> Variant:
	if not node:
		push_error("Cannot get node variable: node is null")
		return default
	
	var node_path: String = str(node.get_path())
	
	# Check memory first
	if node_variables.has(node_path) and node_variables[node_path].has(var_name):
		return node_variables[node_path][var_name]
	
	# Check node metadata
	if node.has_meta("flowkit_variables"):
		var meta_vars: Dictionary = node.get_meta("flowkit_variables")
		if meta_vars.has(var_name):
			var value = meta_vars[var_name]
			
			# Apply type conversion if type metadata exists
			if node.has_meta("flowkit_variable_types"):
				var var_types: Dictionary = node.get_meta("flowkit_variable_types")
				if var_types.has(var_name):
					value = _convert_to_type(value, var_types[var_name])
			
			# Sync to memory
			if not node_variables.has(node_path):
				node_variables[node_path] = {}
			node_variables[node_path][var_name] = value
			return value
	
	return default

func has_node_var(node: Node, var_name: String) -> bool:
	if not node:
		return false
	
	var node_path: String = str(node.get_path())
	
	# Check memory
	if node_variables.has(node_path) and node_variables[node_path].has(var_name):
		return true
	
	# Check metadata
	if node.has_meta("flowkit_variables"):
		var meta_vars: Dictionary = node.get_meta("flowkit_variables")
		return meta_vars.has(var_name)
	
	return false

func clear_node_var(node: Node, var_name: String) -> void:
	if not node:
		return
	
	var node_path: String = str(node.get_path())
	
	# Clear from memory
	if node_variables.has(node_path):
		node_variables[node_path].erase(var_name)
	
	# Clear from metadata
	if node.has_meta("flowkit_variables"):
		var meta_vars: Dictionary = node.get_meta("flowkit_variables")
		meta_vars.erase(var_name)
		node.set_meta("flowkit_variables", meta_vars)

func clear_all_node_vars(node: Node) -> void:
	if not node:
		return
	
	var node_path: String = str(node.get_path())
	
	# Clear from memory
	node_variables.erase(node_path)
	
	# Clear from metadata
	if node.has_meta("flowkit_variables"):
		node.remove_meta("flowkit_variables")

func get_node_variable_names(node: Node) -> Array:
	if not node:
		return []
	
	var node_path: String = str(node.get_path())
	var var_names: Array = []
	
	# Get from memory
	if node_variables.has(node_path):
		for var_name in node_variables[node_path].keys():
			if not var_names.has(var_name):
				var_names.append(var_name)
	
	# Get from metadata
	if node.has_meta("flowkit_variables"):
		var meta_vars: Dictionary = node.get_meta("flowkit_variables")
		for var_name in meta_vars.keys():
			if not var_names.has(var_name):
				var_names.append(var_name)
	
	return var_names

# Sync all node variables from metadata (call this at scene load)
func sync_scene_node_variables(scene_root: Node) -> void:
	if not scene_root:
		return
	
	_sync_node_recursive(scene_root)

func _sync_node_recursive(node: Node) -> void:
	# Sync this node's metadata variables to memory
	if node.has_meta("flowkit_variables"):
		var meta_vars: Dictionary = node.get_meta("flowkit_variables")
		if not meta_vars.is_empty():
			var node_path: String = str(node.get_path())
			if not node_variables.has(node_path):
				node_variables[node_path] = {}
			
			# Get type metadata if available
			var var_types: Dictionary = {}
			if node.has_meta("flowkit_variable_types"):
				var_types = node.get_meta("flowkit_variable_types", {})
			
			for var_name in meta_vars.keys():
				var value = meta_vars[var_name]
				
				# Apply type conversion if type metadata exists
				if var_types.has(var_name):
					value = _convert_to_type(value, var_types[var_name])
				
				node_variables[node_path][var_name] = value
			
			print("[FlowKitSystem] Synced %d variables for node: %s" % [meta_vars.size(), node.name])
	
	# Recursively sync children
	for child in node.get_children():
		_sync_node_recursive(child)

# ProjectSettings helpers
func get_project_setting(path: String, default: Variant = null) -> Variant:
	if ProjectSettings.has_setting(path):
		return ProjectSettings.get_setting(path)
	return default

func set_project_setting(path: String, value: Variant) -> void:
	ProjectSettings.set_setting(path, value)

func has_project_setting(path: String) -> bool:
	return ProjectSettings.has_setting(path)

## Convert a value to the specified type
func _convert_to_type(value: Variant, target_type: String) -> Variant:
	match target_type:
		"int":
			if value is int:
				return value
			if value is float:
				return int(value)
			if value is String:
				return int(value) if value.is_valid_int() else 0
			if value is bool:
				return 1 if value else 0
			return 0
		"float":
			if value is float:
				return value
			if value is int:
				return float(value)
			if value is String:
				return float(value) if value.is_valid_float() else 0.0
			if value is bool:
				return 1.0 if value else 0.0
			return 0.0
		"bool":
			if value is bool:
				return value
			if value is int:
				return value != 0
			if value is float:
				return value != 0.0
			if value is String:
				return value.to_lower() == "true"
			return false
		_:  # String or unknown type
			return str(value)

func get_class() -> String:
	return "FKSystem"
