extends FKEvent

func get_description() -> String:
	return "Fires when AnimationTree animation_finished signal emits (Godot 4.x if available)."

func get_id() -> String:
	return "animtree_on_animation_finished"

func get_name() -> String:
	return "On AnimTree Animation Finished"

func get_supported_types() -> Array[String]:
	return ["AnimationTree"]

func is_signal_event() -> bool:
	return true

var _callback: Callable

func setup(node: Node, trigger_callback: Callable, block_id: String = "") -> void:
	if node == null:
		return
	_callback = func(_anim_name = null): trigger_callback.call()
	if node.has_signal("animation_finished"):
		if not node.is_connected("animation_finished", _callback):
			node.connect("animation_finished", _callback)
	elif node is AnimationTree:
		# Fallback: watch AnimationPlayer if assigned
		var tree := node as AnimationTree
		var player = tree.get("anim_player")
		# anim_player is a NodePath property
		if tree.anim_player:
			var ap = tree.get_node_or_null(tree.anim_player)
			if ap and ap.has_signal("animation_finished"):
				if not ap.animation_finished.is_connected(_callback):
					ap.animation_finished.connect(_callback)

func teardown(node: Node, block_id: String = "") -> void:
	if not is_instance_valid(node) or not _callback.is_valid():
		return
	if node.has_signal("animation_finished") and node.is_connected("animation_finished", _callback):
		node.disconnect("animation_finished", _callback)

func poll(node: Node, inputs: Dictionary = {}, block_id: String = "") -> bool:
	return false
