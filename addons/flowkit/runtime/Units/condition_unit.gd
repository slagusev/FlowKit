@tool
extends FKUnit
class_name FKConditionUnit

@export var condition_id: String = ""
@export var target_node: NodePath
@export var inputs: Dictionary = {}
## When false, condition is skipped (treated as true / not evaluated).
@export var enabled: bool = true
@export var negated: bool = false
## If true, this condition is OR'd with the previous one(s) in the same OR group.
## Conditions with or_with_previous=false start a new AND group.
## Within a group: OR; between groups: AND. Default false preserves legacy all-AND behavior.
@export var or_with_previous: bool = false
@export var actions: Array[FKActionUnit] = [] 

func _init() -> void:
	block_type = "condition"

func may_have_children():
	return true 
	
func get_children() -> Array[FKUnit]:
	var defensive_copy: Array[FKUnit] = [] as Array[FKUnit]
	defensive_copy.append_array(actions)
	return defensive_copy
	
func serialize() -> Dictionary:
	var result := super.serialize()
	var our_added_fields := {
		"condition_id": condition_id,
		"target_node": str(target_node),
		"inputs": inputs.duplicate(),
		"enabled": enabled,
		"negated": negated,
		"or_with_previous": or_with_previous,
	}
	result.merge(our_added_fields)
	
	return result

func deserialize(dict: Dictionary) -> void:
	condition_id = dict.get("condition_id", "")
	target_node = NodePath(dict.get("target_node", ""))
	inputs = dict.get("inputs", {}).duplicate()
	enabled = dict.get("enabled", true)
	negated = dict.get("negated", false)
	or_with_previous = dict.get("or_with_previous", false)

func duplicate_block() -> FKUnit:
	var result: FKConditionUnit = FKConditionUnit.new()
	result.condition_id = condition_id
	result.target_node = str(target_node)
	result.inputs = inputs.duplicate()
	result.enabled = enabled
	result.negated = negated
	result.or_with_previous = or_with_previous
	result.actions = [] as Array[FKActionUnit]
	
	return result
	
func get_id() -> String:
	return condition_id

func get_class() -> String:
	return "FKConditionUnit"
