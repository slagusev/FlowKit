@tool
extends FKUnit
class_name FKEventUnit

@export var block_id: String  # Unique identifier for this specific block instance
@export var event_id: String  # Type of event (e.g., "on_ready", "on_process")
@export var target_node: NodePath
@export var inputs: Dictionary = {}
@export var conditions: Array[FKConditionUnit] = []
@export var actions: Array[FKActionUnit] = []

## When false, the event is skipped at runtime (still visible in editor).
@export var enabled: bool = true
## Fire at most once for the lifetime of the loaded sheet.
@export var trigger_once: bool = false
## Fire only on the rising edge of condition pass (once while true).
@export var once_while_true: bool = false
## When true, engine enters step mode before running this event's actions.
@export var breakpoint_enabled: bool = false

## Runtime-only (not serialized intentionally via @export_storage for save size).
var _runtime_triggered: bool = false
var _runtime_was_passing: bool = false

func may_have_children() -> bool:
	return true

func get_children() -> Array[FKUnit]:
	var defensive_copy: Array[FKUnit] = [] as Array[FKUnit]
	defensive_copy.append_array(conditions)
	defensive_copy.append_array(actions)
	return defensive_copy

func _init(p_block_id: String = "", p_event_id: String = "", 
p_target_node: NodePath = NodePath()) -> void:
	block_type = "event"
	
	if p_block_id.is_empty():
		block_id = _generate_unique_id()
	else:
		block_id = p_block_id
	event_id = p_event_id
	target_node = p_target_node

func _generate_unique_id() -> String:
	"""Generate a unique ID for this block using timestamp and random component."""
	var timestamp = Time.get_unix_time_from_system()
	# event_id can be stuff like "on_ready" and "on_process"
	return "%s_%d_%d" % [event_id if event_id else "event", int(timestamp), randi()]

func ensure_block_id() -> void:
	"""Ensure this block has a unique ID (called when loading from old saved sheets)."""
	if block_id.is_empty():
		block_id = _generate_unique_id()
		
func serialize() -> Dictionary:
	var result := super.serialize()
	var our_added_fields := {
		"block_id": block_id,
		"event_id": event_id,
		"target_node": str(target_node),
		"inputs": inputs.duplicate(),
		"enabled": enabled,
		"trigger_once": trigger_once,
		"once_while_true": once_while_true,
		"breakpoint_enabled": breakpoint_enabled,
		"conditions": [],
		"actions": []
	}
	result.merge(our_added_fields)

	for cond in conditions:
		result["conditions"].append(cond.serialize())

	for act in actions:
		result["actions"].append(act.serialize())

	return result


func deserialize(dict: Dictionary) -> void:
	block_id = dict.get("block_id", "")
	event_id = dict.get("event_id", "")
	target_node = NodePath(dict.get("target_node", ""))
	inputs = dict.get("inputs", {}).duplicate()
	enabled = dict.get("enabled", true)
	trigger_once = dict.get("trigger_once", false)
	once_while_true = dict.get("once_while_true", false)
	breakpoint_enabled = dict.get("breakpoint_enabled", false)
	_runtime_triggered = false
	_runtime_was_passing = false

	conditions = []
	for cond_dict in dict.get("conditions", []):
		var cond := FKConditionUnit.new()
		cond.deserialize(cond_dict)
		conditions.append(cond)

	actions = []
	for act_dict in dict.get("actions", []):
		var act := FKActionUnit.new()
		act.deserialize(act_dict)
		actions.append(act)

func get_id() -> String:
	return block_id
	
func duplicate_block() -> FKUnit:
	var copy := FKEventUnit.new()
	copy.block_type = block_type
	copy.event_id = event_id
	copy.target_node = target_node
	copy.inputs = inputs.duplicate(true)
	copy.enabled = enabled
	copy.trigger_once = trigger_once
	copy.once_while_true = once_while_true
	copy.breakpoint_enabled = breakpoint_enabled
	
	var duplicated_conds: Array[FKConditionUnit] = ArrayUtils.make_fk_condition_dupes(self.conditions)
	copy.conditions.clear()
	copy.conditions.append_array(duplicated_conds)

	var duplicated_acts: Array[FKActionUnit] = ArrayUtils.make_fk_action_dupes(self.actions)
	copy.actions.clear()
	copy.actions.append_array(duplicated_acts)

	return copy
	
func get_class() -> String:
	return "FKEventUnit"
