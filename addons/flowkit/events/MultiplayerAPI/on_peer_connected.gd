extends FKEvent

func get_description() -> String:
	return "Fires when a multiplayer peer connects (uses multiplayer.peer_connected)."

func get_id() -> String:
	return "on_peer_connected"

func get_name() -> String:
	return "On Peer Connected"

func get_supported_types() -> Array[String]:
	return ["Node"]

func is_signal_event() -> bool:
	return true

var _callback: Callable
var _mp: MultiplayerAPI

func setup(node: Node, trigger_callback: Callable, block_id: String = "") -> void:
	if node == null or node.get_tree() == null:
		return
	_mp = node.multiplayer
	if _mp == null:
		return
	_callback = func(_id = 0): trigger_callback.call()
	if not _mp.peer_connected.is_connected(_callback):
		_mp.peer_connected.connect(_callback)

func teardown(node: Node, block_id: String = "") -> void:
	if _mp and _callback.is_valid() and _mp.peer_connected.is_connected(_callback):
		_mp.peer_connected.disconnect(_callback)

func poll(node: Node, inputs: Dictionary = {}, block_id: String = "") -> bool:
	return false
