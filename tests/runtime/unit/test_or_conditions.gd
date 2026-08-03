extends GutTest

## Unit tests for OR-group condition evaluation semantics.
## Mirrors FlowKitEngine._conditions_pass without needing a full tree.


func _group_pass_sim(results: Array, or_flags: Array) -> bool:
	# results[i] = bool outcome of condition i
	# or_flags[i] = or_with_previous for condition i
	if results.is_empty():
		return true
	var groups: Array = []
	var current: Array = []
	for i in range(results.size()):
		var or_prev: bool = or_flags[i] if i < or_flags.size() else false
		if current.is_empty() or not or_prev:
			if not current.is_empty():
				groups.append(current)
			current = [results[i]]
		else:
			current.append(results[i])
	if not current.is_empty():
		groups.append(current)
	for g in groups:
		var any_true := false
		for r in g:
			if r:
				any_true = true
				break
		if not any_true:
			return false
	return true


func test_all_and_legacy():
	# All or_with_previous=false → AND of all
	assert_true(_group_pass_sim([true, true], [false, false]))
	assert_false(_group_pass_sim([true, false], [false, false]))
	assert_false(_group_pass_sim([false, true], [false, false]))


func test_simple_or():
	# A OR B
	assert_true(_group_pass_sim([true, false], [false, true]))
	assert_true(_group_pass_sim([false, true], [false, true]))
	assert_false(_group_pass_sim([false, false], [false, true]))
	assert_true(_group_pass_sim([true, true], [false, true]))


func test_and_of_or_groups():
	# (A OR B) AND C
	# flags: A start, B or, C and (new group)
	assert_true(_group_pass_sim([true, false, true], [false, true, false]))
	assert_true(_group_pass_sim([false, true, true], [false, true, false]))
	assert_false(_group_pass_sim([false, false, true], [false, true, false]))
	assert_false(_group_pass_sim([true, false, false], [false, true, false]))


func test_empty_passes():
	assert_true(_group_pass_sim([], []))


func test_condition_unit_serializes_or_flag():
	var c := FKConditionUnit.new()
	c.condition_id = "x"
	c.or_with_previous = true
	c.negated = true
	var d := c.serialize()
	assert_true(d.get("or_with_previous", false))
	var c2 := FKConditionUnit.new()
	c2.deserialize(d)
	assert_true(c2.or_with_previous)
	assert_true(c2.negated)


func test_duplicate_preserves_or():
	var c := FKConditionUnit.new()
	c.or_with_previous = true
	var copy := c.duplicate_block() as FKConditionUnit
	assert_true(copy.or_with_previous)
