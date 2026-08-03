extends FKAction

func get_description() -> String:
	return "Travels AnimationNodeStateMachinePlayback to a state by name (parameters/playback path)."

func get_id() -> String:
	return "animtree_set_state"

func get_name() -> String:
	return "Set AnimTree State"

func get_supported_types() -> Array[String]:
	return ["AnimationTree"]

func get_inputs() -> Array[FKActionInput]:
	return [_state, _playback]

static var _state: FKStringActionInput:
	get: return FKStringActionInput.new("State", "State machine state name.")

static var _playback: FKStringActionInput:
	get: return FKStringActionInput.new("PlaybackPath", "Parameter path to playback", "parameters/playback")

func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if not (node is AnimationTree):
		return
	var tree := node as AnimationTree
	var state: String = str(_state.get_val(inputs)).strip_edges()
	var path: String = str(_playback.get_val(inputs)).strip_edges()
	if state.is_empty():
		return
	var playback = tree.get(path)
	if playback and playback.has_method("travel"):
		playback.travel(state)
