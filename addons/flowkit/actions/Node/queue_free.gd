extends FKAction

func get_description() -> String:
	return "Queues the target node for deletion at the end of the frame."

func get_id() -> String:
	return "queue_free"

func get_name() -> String:
	return "Queue Free"

func get_supported_types() -> Array[String]:
	return ["Node"]

func get_inputs() -> Array[FKActionInput]:
	return []

func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node and is_instance_valid(node):
		node.queue_free()
