extends Node
class_name NodeUtils

static func queue_free_children(node: Node):
	for c in node.get_children():
		c.queue_free()

# Waits for a node to be ready before proceeding
# This is useful when you need to ensure a node is fully initialized
# before performing operations on it, especially after instantiating
# or when working with nodes that might not be ready yet
#
# Parameters:
#   node: Node - The node to wait for
#   max_wait_time: float - Maximum time in seconds to wait before giving up (default: 5.0)
#   check_interval: float - Time in seconds between readiness checks (default: 0.01)
#
# Returns:
#   bool - true if node became ready, false if timed out
static func wait_until_ready(node: Node, max_wait_time: float = 5.0, check_interval: float = 0.01) -> bool:
	# If node is null, cannot wait
	if not node:
		print("NodeUtils.wait_until_ready: Node is null")
		return false
	
	# If node is already ready, return immediately
	if node.is_inside_tree() and node.is_node_ready():
		return true
	
	# Track elapsed time to prevent infinite waiting
	var elapsed_time: float = 0.0
	
	# Loop until node is ready or we timeout
	while elapsed_time < max_wait_time:
		# Wait for the specified interval before checking again
		await get_tree().create_timer(check_interval).timeout
		elapsed_time += check_interval
		
		# Check if node is now ready
		if node.is_inside_tree() and node.is_node_ready():
			return true
	
	# If we've reached here, we timed out waiting for the node to be ready
	print("NodeUtils.wait_until_ready: Timed out waiting for node to be ready after ", max_wait_time, " seconds")
	return false


# Alternative version with a custom condition function
# Useful when you need to wait for more specific conditions beyond just node ready
#
# Parameters:
#   node: Node - The node to check
#   condition_func: Callable - Function that returns bool when condition is met
#   max_wait_time: float - Maximum time to wait in seconds (default: 5.0)
#   check_interval: float - Time between checks in seconds (default: 0.01)
#
# Returns:
#   bool - true if condition was met, false if timed out
static func wait_for_condition(node: Node, condition_func: Callable, max_wait_time: float = 5.0, check_interval: float = 0.01) -> bool:
	# If node is null, cannot wait
	if not node:
		print("NodeUtils.wait_for_condition: Node is null")
		return false
	
	# Track elapsed time
	var elapsed_time: float = 0.0
	
	# Loop until condition is met or we timeout
	while elapsed_time < max_wait_time:
		# Check if condition is met
		if condition_func.call():
			return true
		
		# Wait before checking again
		await get_tree().create_timer(check_interval).timeout
		elapsed_time += check_interval
	
	# Timed out
	print("NodeUtils.wait_for_condition: Timed out waiting for condition after ", max_wait_time, " seconds")
	return false


# Convenience function to wait for a node to be added to the scene tree
# Useful when you've instantiated a node but haven't added it to the tree yet
#
# Parameters:
#   node: Node - The node to wait for
#   max_wait_time: float - Maximum time to wait in seconds (default: 5.0)
#
# Returns:
#   bool - true if node is in tree, false if timed out
static func wait_until_in_tree(node: Node, max_wait_time: float = 5.0) -> bool:
	# If node is null, cannot wait
	if not node:
		print("NodeUtils.wait_until_in_tree: Node is null")
		return false
	
	# If already in tree, return immediately
	if node.is_inside_tree():
		return true
	
	# Track elapsed time
	var elapsed_time: float = 0.0
	var check_interval: float = 0.01
	
	# Loop until node is in tree or we timeout
	while elapsed_time < max_wait_time:
		await get_tree().create_timer(check_interval).timeout
		elapsed_time += check_interval
		
		if node.is_inside_tree():
			return true
	
	print("NodeUtils.wait_until_in_tree: Timed out waiting for node to be added to tree")
	return false
