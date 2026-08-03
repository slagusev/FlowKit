extends GutTest

func test_undo_basic_behavior():
	var state_tracker := FKSheetStateTracker.new()
	state_tracker.enabled = true

	var firstSnapshot: Array[FKUnit] = [FKEventUnit.new()]
	var secondSnapshot: Array[FKUnit] = [FKEventUnit.new(), FKConditionUnit.new()]

	state_tracker.record_snapshot(firstSnapshot)
	state_tracker.record_snapshot(secondSnapshot)

	assert_true(state_tracker.has_previous())

	var result := state_tracker.get_previous_snapshot(secondSnapshot)

	# Undo should return the last recorded snapshot before current (secondSnapshot copy)
	assert_true(result.size() >= 1)
	assert_true(result[0] is FKEventUnit)

	# Redo stack should now contain a deep copy of the state we undid from
	assert_true(state_tracker.has_next())

func test_undo_manager_deep_copy():
	var state_tracker := FKSheetStateTracker.new()
	state_tracker.enabled = true

	var evBlock := FKEventUnit.new()
	evBlock.inputs = {"x": 1}
	var state: Array[FKUnit] = [evBlock]

	state_tracker.record_snapshot(state)

	# Mutate original after pushing
	evBlock.inputs["x"] = 999

	var popped := state_tracker.get_previous_snapshot(state)

	# The snapshot must NOT reflect the mutation
	assert_eq(popped[0].inputs["x"], 1)

	# And must not be the same instance
	var deep_copy_success := not is_same(popped[0], evBlock)
	assert_true(deep_copy_success)


func test_redo_restores_state():
	var state_tracker := FKSheetStateTracker.new()
	state_tracker.enabled = true

	var firstSnapshot: Array[FKUnit] = [FKEventUnit.new()]
	var secondSnapshot: Array[FKUnit] = [FKEventUnit.new(), FKActionUnit.new()]

	state_tracker.record_snapshot(firstSnapshot)
	state_tracker.record_snapshot(secondSnapshot)

	var undo_result := state_tracker.get_previous_snapshot(secondSnapshot)
	assert_true(undo_result.size() >= 1)

	var redo_result := state_tracker.get_next_snapshot(undo_result)
	assert_eq(redo_result.size(), secondSnapshot.size())
	assert_true(redo_result[1] is FKActionUnit)


func test_disabled_tracker_is_noop():
	var state_tracker := FKSheetStateTracker.new()
	# enabled defaults to false
	var snap: Array[FKUnit] = [FKEventUnit.new()]
	state_tracker.record_snapshot(snap)
	assert_false(state_tracker.has_previous())
