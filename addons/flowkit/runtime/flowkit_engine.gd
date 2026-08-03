extends Node
class_name FlowKitEngine

const ExpressionEvaluator = preload("res://addons/flowkit/runtime/expression_evaluator.gd")

var registry: FKRegistry
var active_sheets: Array = []  # Each entry: {"sheet": FKEventSheet, "root": Node, "scene_name": String, "uid": int}
var last_scene: Node = null
var active_behavior_nodes: Array = []  # Track nodes with active behaviors
var _block_event_providers: Dictionary = {}  # block_id -> per-block event provider instance
var _branch_executor := FKBranchExecutor.new()

func _ready() -> void:
	# Load registry
	registry = FKRegistry.new()
	registry.load_all()
	_branch_executor.fk_engine = self
	_branch_executor.registry = registry

	print("[FlowKit] Engine initialized.")

	# Debug overlay in debug builds (or when project setting enabled)
	call_deferred("_maybe_add_debug_overlay")

	# Do a deferred check in case the scene is already present at startup.
	call_deferred("_check_current_scene")

func _maybe_add_debug_overlay() -> void:
	var enable := OS.is_debug_build()
	if ProjectSettings.has_setting("flowkit/debug_overlay"):
		enable = bool(ProjectSettings.get_setting("flowkit/debug_overlay"))
	if not enable:
		return
	if get_node_or_null("FKDebugOverlay"):
		return
	var overlay_script = load("res://addons/flowkit/runtime/debug_overlay.gd")
	if overlay_script:
		var overlay = overlay_script.new()
		overlay.name = "FKDebugOverlay"
		add_child(overlay)

var _is_physics_frame: bool = false  # Tracks which callback is currently running

const _path_to_sys := NodePath("/root/FlowKitSystem")
const _sys_node_name := "System"
func _resolve_target(target: String, root: Node) -> Node:
	if target == _sys_node_name:
		return get_node(_path_to_sys)
	return root.get_node_or_null(target)

func _process(delta: float) -> void:
	# Regularly check if the current_scene changed (robust against timing issues).
	_check_for_scene_change()
	# Store delta on FlowKitSystem so expressions can read it
	var system = get_node_or_null(_path_to_sys)
	if system:
		system.delta = delta
	_is_physics_frame = false
	for entry in active_sheets:
		_run_sheet(entry)
	
	# Process behaviors (process callback)
	_process_behaviors(delta, false)

func _physics_process(delta: float) -> void:
	# Store delta on FlowKitSystem so expressions can read it
	var system = get_node_or_null(_path_to_sys)
	if system:
		system.delta = delta
	_is_physics_frame = true
	# Run sheets in physics process for physics-based events
	for entry in active_sheets:
		_run_sheet(entry)
	
	# Process behaviors (physics_process callback)
	_process_behaviors(delta, true)


# --- Scene detection helpers -----------------------------------------------
func _check_current_scene() -> void:
	var cs: Node = get_tree().current_scene
	if cs:
		_on_scene_changed(cs)

func _check_for_scene_change() -> void:
	var cs: Node = get_tree().current_scene
	if cs != last_scene:
		# Scene changed (including from null -> scene)
		_on_scene_changed(cs)


func _on_scene_changed(scene_root: Node) -> void:
	last_scene = scene_root
	active_behavior_nodes.clear()  # Clear behavior tracking on scene change
	
	# Teardown signal events on previous sheets before clearing
	_teardown_all_signal_events()
	_block_event_providers.clear()
	
	if scene_root == null:
		# Scene unloaded: clear active sheets (optional)
		active_sheets.clear()
		print("[FlowKit] Scene cleared.")
		return

	var scene_path: String = scene_root.scene_file_path
	var scene_uid = ResourceLoader.get_resource_uid(scene_path)
	var scene_name: String = scene_path.get_file().get_basename()
	print("[FlowKit] Scene detected:", scene_name, " (", scene_root.name, ") UID:", scene_uid)

	# Sync node variables from metadata to FlowKitSystem
	var system: Node = get_tree().root.get_node_or_null(_path_to_sys)
	if system and system.has_method("sync_scene_node_variables"):
		system.sync_scene_node_variables(scene_root)

	# Scan and activate behaviors for all nodes in the scene
	_scan_and_activate_behaviors(scene_root)

	# Load event sheets for the scene root and any instanced child scenes
	_load_sheets_for_scene(scene_root)



func _load_sheets_for_scene(scene_root: Node) -> void:
	# Clear previous sheets
	active_sheets.clear()

	# Collect unique scene_file_path UIDs and map to their root node instances
	var uid_to_node: Dictionary = {}

	# Start from the scene root
	_collect_node_paths(scene_root, uid_to_node)

	# Load sheets for each discovered scene UID (project-local + legacy paths)
	var sheet_io := FKSheetIO.new()
	for uid in uid_to_node.keys():
		var node_root: Node = uid_to_node[uid]
		var scene_path: String = node_root.scene_file_path
		var scene_name: String = scene_path.get_file().get_basename()
		var sheet: FKEventSheet = sheet_io.load_sheet(uid, scene_name)

		if sheet:
			# Ensure all blocks have unique IDs (for backward compatibility with old saved sheets)
			for block in sheet.events:
				if block:
					block.ensure_block_id()
					block._runtime_triggered = false
					block._runtime_was_passing = false
			# Also ensure block IDs for events inside groups
			_ensure_block_ids_in_groups(sheet.groups)
			var entry := {"sheet": sheet, "root": node_root, "scene_name": scene_name, "uid": uid}
			active_sheets.append(entry)
			# Init sheet-local variables on FlowKitSystem
			var system = get_node_or_null(_path_to_sys)
			if system and system.has_method("init_sheet_vars"):
				system.init_sheet_vars(uid, sheet.build_sheet_var_defaults())
			# Create per-block event provider instances (each block gets its own)
			_create_block_providers(entry)
			# Setup signal-based events so they can connect to node signals
			_setup_signal_events(entry)
			print("[FlowKit] Loaded event sheet for scene: ", scene_name, " (node: ", node_root.name, ") with ", sheet.events.size(), " events")
		else:
			print("[FlowKit] No sheet found for scene: ", scene_name, " (uid: ", uid, ")")


# Helper method moved outside
func _collect_node_paths(node: Node, uid_to_node: Dictionary) -> void:
	var path: String = node.scene_file_path
	if path and path != "":
		# Only consider nodes that are the topmost root of their instanced scene
		var parent = node.get_parent()
		var parent_path: String = ""
		if parent:
			parent_path = parent.scene_file_path

		if parent_path != path:
			var uid = ResourceLoader.get_resource_uid(path)
			if uid >= 0 and not uid_to_node.has(uid):
				uid_to_node[uid] = node

	for child in node.get_children():
		_collect_node_paths(child, uid_to_node)


## Create a new event provider instance for each event block in a sheet entry.
## This ensures each block has its own isolated state.
func _create_block_providers(entry: Dictionary) -> void:
	var sheet: FKEventSheet = entry.get("sheet", null)
	if not sheet:
		return

	var all_events: Array = sheet.get_all_events()

	for block in all_events:
		if block.block_id and not _block_event_providers.has(block.block_id):
			var instance = registry.create_event_instance(block.event_id)
			if instance:
				_block_event_providers[block.block_id] = instance

func _get_all_events(sheet: FKEventSheet) -> Array:
	var events: Array = []
	events.append_array(sheet.events)
	_collect_events_from_groups(sheet.groups, events)
	return events

func _run_sheet(entry: Dictionary) -> void:
	# Entry is a dictionary with keys: "sheet" and "root"
	var sheet: FKEventSheet = entry.get("sheet", null)
	var root_node: Node = entry.get("root", null)
	var sheet_uid: int = int(entry.get("uid", 0))

	if not sheet:
		return

	# Root node for resolving node paths in this sheet
	var current_root: Node = root_node
	if not current_root or not is_instance_valid(current_root):
		# If the root is invalid, skip this sheet
		return

	# Bind sheet context for expressions / sheet vars / call subsheet
	var system = get_node_or_null(_path_to_sys)
	if system and system.has_method("set_active_sheet"):
		system.set_active_sheet(sheet_uid)
	# Store on self for actions that call run_subsheet
	_active_entry = entry

	# Process standalone conditions (run every frame)
	for standalone_cond in sheet.standalone_conditions:
		var target := str(standalone_cond.target_node)
		var cnode: Node = _resolve_target(target, current_root)
		if not cnode:
			continue

		var cond_result: bool = registry.check_condition(standalone_cond.condition_id, cnode, standalone_cond.inputs, standalone_cond.negated, current_root, "")
		if cond_result:
			# Execute actions associated with this standalone condition
			for act in standalone_cond.actions:
				target = str(act.target_node)
				var anode: Node = _resolve_target(target, current_root)
				if not anode:
					print("[FlowKit] Standalone condition action target node not found: ", act.target_node)
					continue
				var provider: Variant = await registry.execute_action(act.action_id, anode, act.inputs, current_root, "")


	# Collect all events from the sheet (both top-level and nested in groups)
	var all_events: Array = sheet.get_all_events()

	# Process each block individually
	for block in all_events:
		if block == null or not block.enabled:
			continue
		# Resolve target node for polling
		var target: String = block.target_node
		var node: Node = _resolve_target(target, current_root)
		
		if not node:
			print("[FlowKit] Event polling target node not found: ", block.target_node, " in scene root: ", current_root.name)
			continue

		# Get the per-block event provider instance
		var provider = _block_event_providers.get(block.block_id, null)
		if not provider:
			continue

		# Signal events fire via callback — skip them in the poll loop
		if provider.has_method("is_signal_event") and provider.is_signal_event():
			continue

		# Skip events that belong to the wrong callback
		# on_process_physics should only run during _physics_process
		# on_process should only run during _process
		if block.event_id == "on_process_physics" and not _is_physics_frame:
			continue
		if block.event_id == "on_process" and _is_physics_frame:
			continue

		# Poll the event with the per-block provider instance
		if not provider.has_method("poll"):
			continue
		var evaluated_inputs: Dictionary = ExpressionEvaluator.evaluate_inputs(block.inputs, node, current_root)
		var event_triggered = provider.poll(node, evaluated_inputs, block.block_id)
		if not event_triggered:
			continue

		# Execute the block's conditions and actions
		_execute_block(block, current_root, sheet_uid)

var _active_entry: Dictionary = {}
# --- Signal event lifecycle -------------------------------------------------

## Set up signal-based events for a loaded sheet entry.
## For each event block, calls registry.setup_event() with a trigger callback
## so signal events can connect to Godot signals and fire immediately.
func _setup_signal_events(entry: Dictionary) -> void:
	var sheet: FKEventSheet = entry.get("sheet", null)
	var root_node: Node = entry.get("root", null)
	var sheet_uid: int = int(entry.get("uid", 0))
	if not sheet or not root_node or not is_instance_valid(root_node):
		return

	var all_events: Array = sheet.get_all_events()

	for block in all_events:
		if block == null or not block.enabled:
			continue
		var provider = _block_event_providers.get(block.block_id, null)
		if not provider:
			continue

		if not (provider.has_method("is_signal_event") and provider.is_signal_event()):
			continue

		var target := str(block.target_node)
		var node: Node = _resolve_target(target, root_node)
		if not node:
			continue

		# Build a trigger callback that runs this block's conditions & actions
		var trigger_cb: Callable = _make_trigger_callback(block, root_node, sheet_uid)
		if provider.has_method("setup"):
			provider.setup(node, trigger_cb, block.block_id)

## Teardown all signal events across every active sheet.
func _teardown_all_signal_events() -> void:
	for entry in active_sheets:
		var sheet: FKEventSheet = entry.get("sheet", null)
		var root_node: Node = entry.get("root", null)
		if not sheet or not root_node or not is_instance_valid(root_node):
			continue

		var all_events: Array = sheet.get_all_events()

		for block in all_events:
			var provider = _block_event_providers.get(block.block_id, null)
			if not provider:
				continue
			
			var target := str(block.target_node)
			var node: Node = _resolve_target(target, root_node)
			if not node:
				continue

			if provider.has_method("teardown"):
				provider.teardown(node, block.block_id)

## Create a Callable that evaluates a block's conditions and runs its actions.
## This is what signal events call when their signal fires.
func _make_trigger_callback(block: FKEventUnit, current_root: Node, sheet_uid: int = 0) -> Callable:
	return func() -> void:
		if not is_instance_valid(current_root):
			return
		_execute_block(block, current_root, sheet_uid)

## Execute a single event block: check all conditions, then run all actions.
## Shared by both the poll loop and signal-based trigger callbacks.
func _execute_block(block: FKEventUnit, current_root: Node, sheet_uid: int = 0) -> void:
	if block == null or not block.enabled:
		return
	if block.trigger_once and block._runtime_triggered:
		return
	
	var cond_ok := _conditions_pass(block.conditions, current_root, block.block_id)
	
	if block.once_while_true:
		if cond_ok and block._runtime_was_passing:
			return  # still true from last frame — skip
		if not cond_ok:
			block._runtime_was_passing = false
			return
		block._runtime_was_passing = true
	elif not cond_ok:
		_debug(current_root, "cond_fail", "Event %s conditions failed" % block.event_id)
		return
	
	if block.trigger_once:
		block._runtime_triggered = true
	
	_set_debug_active(block.block_id, block.event_id, "")
	_debug(current_root, "event", "Fired %s on %s" % [block.event_id, str(block.target_node)])
	
	# Breakpoint: force step mode before actions
	if block.breakpoint_enabled:
		var system = get_node_or_null(_path_to_sys)
		if system and "debug_step_mode" in system:
			system.debug_step_mode = true
		await debug_wait_if_stepping("breakpoint", "%s (%s)" % [block.event_id, block.block_id])
	
	# Execute all actions (with branch support, including nested branches)
	await _execute_actions_list(block.actions, current_root, block.block_id)
	_set_debug_active("", "", "")

func _set_debug_active(block_id: String, event_id: String, action_id: String) -> void:
	var system = get_node_or_null(_path_to_sys)
	if system == null:
		return
	if "debug_active_block_id" in system:
		system.debug_active_block_id = block_id
	if "debug_active_event_id" in system:
		system.debug_active_event_id = event_id
	if "debug_active_action_id" in system:
		system.debug_active_action_id = action_id
	if system.has_method("debug_push") and not block_id.is_empty():
		system.debug_push("highlight", "▶ %s · %s" % [event_id, action_id if not action_id.is_empty() else "event"])

func _debug(from: Node, kind: String, msg: String) -> void:
	var system = get_node_or_null(_path_to_sys)
	if system and system.has_method("debug_push"):
		system.debug_push(kind, msg)

## Evaluate event conditions with OR groups:
## - Conditions with or_with_previous=false start a new AND-group
## - Subsequent or_with_previous=true conditions join that group as OR
## - Groups are AND'd together
## Empty list → pass (same as legacy).
## Disabled conditions are skipped (do not affect the group).
func _conditions_pass(conditions: Array, current_root: Node, block_id: String) -> bool:
	if conditions.is_empty():
		return true
	
	# Build OR groups
	var groups: Array = []  # Array of Array[FKConditionUnit]
	var current_group: Array = []
	for cond in conditions:
		if cond == null:
			continue
		if "enabled" in cond and not cond.enabled:
			continue
		if current_group.is_empty() or not cond.or_with_previous:
			if not current_group.is_empty():
				groups.append(current_group)
			current_group = [cond]
		else:
			current_group.append(cond)
	if not current_group.is_empty():
		groups.append(current_group)
	
	# AND of groups; each group is OR of its members
	for gi in range(groups.size()):
		var group = groups[gi]
		var group_passed := false
		var fail_details: PackedStringArray = []
		for cond in group:
			var detail := {}
			if _check_single_condition(cond, current_root, block_id, detail):
				group_passed = true
				break
			else:
				fail_details.append(str(detail.get("explain", cond.condition_id)))
		if not group_passed:
			_debug(current_root, "cond_fail", "AND-group %d failed: %s" % [gi, " | ".join(fail_details)])
			var system = get_node_or_null(_path_to_sys)
			if system and "last_cond_fail" in system:
				system.last_cond_fail = " | ".join(fail_details)
			return false
	return true

func _check_single_condition(cond: FKConditionUnit, current_root: Node, block_id: String, detail: Dictionary = {}) -> bool:
	var target := str(cond.target_node)
	var cnode: Node = _resolve_target(target, current_root)
	if not cnode:
		detail["explain"] = "%s: target missing (%s)" % [cond.condition_id, target]
		return false
	var ok: bool = registry.check_condition(
		cond.condition_id, cnode, cond.inputs, cond.negated, current_root, block_id
	)
	if not ok:
		var neg := " NOT" if cond.negated else ""
		detail["explain"] = "%s%s @ %s inputs=%s" % [cond.condition_id, neg, target, str(cond.inputs)]
	return ok

## Debug step mode: F8 toggles, F9 continues one step.
var debug_step_mode: bool = false
var _debug_step_continue: bool = false

func record_profile(action_id: String, elapsed_us: int) -> void:
	var system = get_node_or_null(_path_to_sys)
	if system == null or not ("profile_stats" in system):
		return
	var st: Dictionary = system.profile_stats.get(action_id, {"count": 0, "total_us": 0, "last_us": 0})
	st["count"] = int(st.get("count", 0)) + 1
	st["total_us"] = int(st.get("total_us", 0)) + elapsed_us
	st["last_us"] = elapsed_us
	system.profile_stats[action_id] = st

func debug_wait_if_stepping(kind: String, msg: String) -> void:
	var system = get_node_or_null(_path_to_sys)
	if system and "debug_step_mode" in system:
		debug_step_mode = system.debug_step_mode
	if not debug_step_mode:
		return
	_debug(null, "step", "⏸ %s: %s  (F9 continue · F8 exit step)" % [kind, msg])
	_debug_step_continue = false
	if system:
		system.debug_step_waiting = true
		system.debug_step_label = "%s: %s" % [kind, msg]
	while debug_step_mode and not _debug_step_continue:
		if system and "debug_step_mode" in system:
			debug_step_mode = system.debug_step_mode
		if system and system.get("debug_step_request_continue"):
			system.debug_step_request_continue = false
			_debug_step_continue = true
			break
		await get_tree().process_frame
	if system:
		system.debug_step_waiting = false

## Execute a list of actions, handling branch chains via providers.
## Used by both _execute_block (top-level actions) and nested branches.
func _execute_actions_list(actions: Array, current_root: Node, block_id: String) -> void:
	await _branch_executor._execute_actions(actions, current_root, block_id)

## Run a named subsheet's actions (called from Call Subsheet action).
## optional_args merges over subsheet parameter defaults and is exposed as p_name / system.subsheet_params.
func run_subsheet(sub_name: String, current_root: Node = null, optional_args: Dictionary = {}) -> void:
	var entry := _active_entry
	var sheet: FKEventSheet = entry.get("sheet", null)
	if sheet == null:
		for e in active_sheets:
			if e.get("root") == current_root:
				sheet = e.get("sheet")
				entry = e
				break
	if sheet == null:
		push_warning("[FlowKit] run_subsheet: no active sheet for '%s'" % sub_name)
		return
	var sub = sheet.find_subsheet(sub_name)
	if sub == null:
		push_warning("[FlowKit] Subsheet not found: '%s'" % sub_name)
		return
	var root: Node = current_root if current_root else entry.get("root")
	var system = root.get_tree().root.get_node_or_null("/root/FlowKitSystem") if root and root.get_tree() else null
	var param_map: Dictionary = {}
	if sub.has_method("build_param_defaults"):
		param_map = sub.build_param_defaults()
	elif "parameters" in sub and sub.parameters is Array:
		for p in sub.parameters:
			if p is Dictionary:
				var pn := str(p.get("name", "")).strip_edges()
				if not pn.is_empty():
					param_map[pn] = p.get("default", null)
	for k in optional_args.keys():
		param_map[k] = optional_args[k]
	if system and "subsheet_params" in system:
		system.subsheet_params = param_map
	_debug(root, "subsheet", "Call subsheet '%s' params=%s" % [sub_name, str(param_map)])
	await _execute_actions_list(sub.actions, root, "subsheet_" + sub_name)
	if system and "subsheet_params" in system:
		system.subsheet_params = {}

## Find nodes in scene by group and/or class for For Each.
func find_nodes_for_each(root: Node, group_name: String, class_name_str: String) -> Array:
	var results: Array = []
	if root == null:
		return results
	var g := group_name.strip_edges()
	var c := class_name_str.strip_edges()
	if not g.is_empty():
		var from_group = root.get_tree().get_nodes_in_group(g)
		for n in from_group:
			if c.is_empty() or n.get_class() == c or ClassDB.is_parent_class(n.get_class(), c):
				results.append(n)
		return results
	if not c.is_empty():
		_collect_by_class(root, c, results)
	return results

func _collect_by_class(node: Node, class_name_str: String, out: Array) -> void:
	if node.get_class() == class_name_str or ClassDB.is_parent_class(node.get_class(), class_name_str):
		out.append(node)
	for child in node.get_children():
		_collect_by_class(child, class_name_str, out)
	
func _is_multi_frame_provider(provider: Variant) -> bool:
	return provider and provider.has_method("requires_multi_frames") and provider.requires_multi_frames()

func _collect_events_from_groups(groups: Array, out_events: Array) -> void:
	for group in groups:
		if group is FKGroup:
			for child_item in group.children:
				var child_type: String = child_item.get("type", "")
				var child_data: Variant = child_item.get("data", null)
				
				if child_type == "event" and child_data is FKEventUnit:
					out_events.append(child_data)
				elif child_type == "group" and child_data is FKGroup:
					# Recursively collect from nested groups
					_collect_events_from_groups([child_data], out_events)


func _ensure_block_ids_in_groups(groups: Array) -> void:
	"""
	Recursively ensure all FKEventUnit instances inside FKGroup children
	have unique block IDs. Supports both legacy dictionary children and
	new FKUnit-only children.
	"""
	for group in groups:
		if not (group is FKGroup):
			continue

		for child in group.children:
			var unit: FKUnit = null

			# Legacy format: { "type": String, "data": FKUnit }
			if child is Dictionary:
				unit = child.get("data")
			else:
				unit = child

			if unit is FKEventUnit:
				unit.ensure_block_id()

			elif unit is FKGroup:
				# Recurse into nested groups
				_ensure_block_ids_in_groups([unit])

# --- Behavior processing ---------------------------------------------------
func _scan_and_activate_behaviors(scene_root: Node) -> void:
	# Recursively scan all nodes in the scene for behaviors
	_scan_node_for_behavior(scene_root)

func _scan_node_for_behavior(node: Node) -> void:
	# Multi-behavior meta (+ legacy single-slot) via FKBehaviorMeta
	var behaviors: Array = FKBehaviorMeta.get_behaviors(node)
	if not behaviors.is_empty():
		var scene_root = get_tree().current_scene
		for behavior_data in behaviors:
			var behavior_id: String = str(behavior_data.get("id", ""))
			var inputs: Dictionary = behavior_data.get("inputs", {}) if behavior_data.get("inputs", {}) is Dictionary else {}
			if behavior_id.is_empty():
				continue
			registry.apply_behavior(behavior_id, node, inputs, scene_root)
			print("[FlowKit] Activated behavior '%s' on node: %s" % [behavior_id, node.name])
		if not active_behavior_nodes.has(node):
			active_behavior_nodes.append(node)
	
	# Recursively scan children
	for child in node.get_children():
		_scan_node_for_behavior(child)

func _process_behaviors(delta: float, is_physics: bool) -> void:
	# Process all active behaviors (multi-slot)
	var valid_nodes: Array = []
	for node in active_behavior_nodes:
		if is_instance_valid(node):
			valid_nodes.append(node)
	active_behavior_nodes = valid_nodes
	
	for node in active_behavior_nodes:
		var behaviors: Array = FKBehaviorMeta.get_behaviors(node)
		if behaviors.is_empty():
			continue
		for behavior_data in behaviors:
			var behavior_id: String = str(behavior_data.get("id", ""))
			var inputs: Dictionary = behavior_data.get("inputs", {}) if behavior_data.get("inputs", {}) is Dictionary else {}
			if behavior_id.is_empty():
				continue
			var behavior: Variant = registry.get_behavior(behavior_id)
			if not behavior:
				continue
			if is_physics:
				if behavior.has_method("physics_process"):
					behavior.physics_process(node, delta, inputs)
			else:
				if behavior.has_method("process"):
					behavior.process(node, delta, inputs)

## Runtime register a node for behavior process loops (used by Apply Behavior action).
func track_behavior_node(node: Node) -> void:
	if node and is_instance_valid(node) and not active_behavior_nodes.has(node):
		active_behavior_nodes.append(node)

func get_class() -> String:
	return "FlowKitEngine"
