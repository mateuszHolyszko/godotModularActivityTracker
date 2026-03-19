extends Node
class_name NodeUtils

static func queue_free_children(node: Node):
	for c in node.get_children():
		c.queue_free()
