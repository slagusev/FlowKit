@tool
extends EditorDebuggerPlugin
class_name FKEditorDebuggerPlugin
## Receives runtime FlowKit debug messages during Play (editor ↔ game).

var globals: FKEditorGlobals = null


func _has_capture(capture: String) -> bool:
	return capture == "flowkit"


func _capture(message: String, data: Array, _session_id: int) -> bool:
	if globals == null:
		return false
	if message == "flowkit:active":
		globals.debug_play_block_id = str(data[0]) if data.size() > 0 else ""
		globals.debug_play_event_id = str(data[1]) if data.size() > 1 else ""
		globals.debug_play_action_id = str(data[2]) if data.size() > 2 else ""
		globals.debug_play_tick = Time.get_ticks_msec()
		return true
	if message == "flowkit:clear":
		globals.debug_play_block_id = ""
		globals.debug_play_event_id = ""
		globals.debug_play_action_id = ""
		globals.debug_play_tick = Time.get_ticks_msec()
		return true
	return false
