extends RefCounted
class_name FKConditionGroups
## Pure helpers for OR/AND condition grouping (testable without SceneTree).


## Build OR groups from a condition list.
## Skips null and disabled conditions.
## Returns Array of Array[FKConditionUnit] (or whatever was passed).
static func build_or_groups(conditions: Array) -> Array:
	var groups: Array = []
	var current_group: Array = []
	for cond in conditions:
		if cond == null:
			continue
		if "enabled" in cond and not cond.enabled:
			continue
		var or_prev := false
		if "or_with_previous" in cond:
			or_prev = bool(cond.or_with_previous)
		if current_group.is_empty() or not or_prev:
			if not current_group.is_empty():
				groups.append(current_group)
			current_group = [cond]
		else:
			current_group.append(cond)
	if not current_group.is_empty():
		groups.append(current_group)
	return groups


## Evaluate groups where each group is OR of bools, groups are AND'd.
## group_results: Array of Array[bool]
static func evaluate_group_bools(group_results: Array) -> bool:
	if group_results.is_empty():
		return true
	for group in group_results:
		var any_true := false
		for r in group:
			if r:
				any_true = true
				break
		if not any_true:
			return false
	return true


## Simulate outcomes: parallel arrays of pass bool + or_with_previous.
static func simulate_flags(pass_results: Array, or_flags: Array) -> bool:
	if pass_results.is_empty():
		return true
	var groups: Array = []
	var current: Array = []
	for i in range(pass_results.size()):
		var or_prev: bool = or_flags[i] if i < or_flags.size() else false
		if current.is_empty() or not or_prev:
			if not current.is_empty():
				groups.append(current)
			current = [pass_results[i]]
		else:
			current.append(pass_results[i])
	if not current.is_empty():
		groups.append(current)
	return evaluate_group_bools(groups)
