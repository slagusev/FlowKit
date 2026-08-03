extends RefCounted
class_name FKObjectActivate
## After editor/runtime pack or recipe changes, re-apply behaviors and track object nodes.


static func refresh_scene(from_node: Node) -> void:
	if from_node == null or from_node.get_tree() == null:
		return
	var root := from_node.get_tree().current_scene
	if root == null:
		root = from_node
	var engine = from_node.get_tree().root.get_node_or_null("/root/FlowKit")
	if engine == null:
		return
	if engine.has_method("_scan_and_activate_behaviors"):
		engine._scan_and_activate_behaviors(root)
	if engine.has_method("_scan_object_nodes"):
		engine._scan_object_nodes(root)
	# Ensure system has score bucket for collectibles
	var system = from_node.get_tree().root.get_node_or_null("/root/FlowKitSystem")
	if system and system.has_method("set_sheet_var") and system.has_method("has_sheet_var"):
		if not system.has_sheet_var("score"):
			system.set_sheet_var("score", 0)
