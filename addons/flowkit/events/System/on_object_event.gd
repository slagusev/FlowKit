extends FKEvent

func get_description() -> String:
	return "Fires when FlowKitSystem emits an object event (from Emit Object Event action or Object Mode rules)."

func get_id() -> String:
	return "on_object_event"

func get_name() -> String:
	return "On Object Event"

func get_supported_types() -> Array[String]:
	return ["System", "Node"]

func get_inputs() -> Array:
	return [
		FKStringActionInput.new("Event", "Listen for this event name (empty = any)"),
		FKStringActionInput.new("SourceGroup", "Optional: only if source is in this group"),
	]

func is_signal_event() -> bool:
	return true

var _trigger: Callable
var _event_filter: String = ""
var _group_filter: String = ""
var _system: Node = null

func configure_filters(event_name: String, source_group: String = "") -> void:
	_event_filter = event_name.strip_edges()
	_group_filter = source_group.strip_edges()

func setup(node: Node, trigger_callback: Callable, block_id: String = "") -> void:
	var keep_event := _event_filter
	var keep_group := _group_filter
	teardown(node, block_id)
	_event_filter = keep_event
	_group_filter = keep_group
	_trigger = trigger_callback
	# Prefer the setup node when it already is the bus (autoload or test instance).
	if node != null and is_instance_valid(node) and node.has_signal("object_event"):
		_system = node
	else:
		_system = _resolve_system(node)
	if _system != null and _system.has_signal("object_event"):
		var cb := Callable(self, "_on_bus")
		if not _system.object_event.is_connected(cb):
			_system.object_event.connect(cb)

func _on_bus(event_name: String, source: Node, payload: Dictionary) -> void:
	if not _event_filter.is_empty() and event_name != _event_filter:
		return
	if not _group_filter.is_empty():
		if source == null or not source.is_in_group(_group_filter):
			return
	if _system != null and is_instance_valid(_system):
		if "variables" in _system:
			_system.variables["last_object_event"] = event_name
			_system.variables["last_object_source"] = source
			_system.variables["last_object_payload"] = payload
	if _trigger.is_valid():
		_trigger.call()

func teardown(node: Node, _block_id: String = "") -> void:
	if _system != null and is_instance_valid(_system) and _system.has_signal("object_event"):
		var cb := Callable(self, "_on_bus")
		if _system.object_event.is_connected(cb):
			_system.object_event.disconnect(cb)
	_system = null
	_trigger = Callable()

func _resolve_system(from_node: Node) -> Node:
	if from_node != null and is_instance_valid(from_node) and from_node.is_inside_tree():
		var tree := from_node.get_tree()
		if tree and tree.root:
			var s = tree.root.get_node_or_null("/root/FlowKitSystem")
			if s:
				return s
	var ml = Engine.get_main_loop()
	if ml is SceneTree:
		var st := ml as SceneTree
		if st.root:
			return st.root.get_node_or_null("/root/FlowKitSystem")
	return null
