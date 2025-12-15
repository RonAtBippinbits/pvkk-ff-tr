extends Node
class_name DeviceValidator

# Modules can use this class to validate that the connected devices are fitting.
# Each device type is defined to have certain methods that return certain values.

# get_percentage should always return a value between 0.0 and 1.0
# Must implement this
#func init(formatter:Callable, min_value = 0, max_value = 100, unit:String = "%"):
#	pass
#
#func get_percentage() -> float:
#	return 0.0

static func assert_numeric_input(node:Node):
	assert(must_be_numeric_input("",node))
	
static func must_be_numeric_input(n, node:Node) -> bool:
	if node == null:
		Logger.error("Node is not a numeric input. It is null.", n)
		return false
	
	if not node.has_method("get_percentage"):
		Logger.error("Node " + node.name + " is not a numeric input. It has no function 'get_percentage'.", n)
		return false

	var result = node.get_percentage()
	if not result is float:
		Logger.error("Node " + node.name + " is not a numeric input. The function 'get_percentage' does not return a float.", n)
		return false
	
	if not node.has_method("set_absolute_value"):
		Logger.error("Node " + node.name + " is not a numeric input. It has no function 'set_absolute_value'.", n)
		return false
	
	if not node.has_method("get_absolute_value"):
		Logger.error("Node " + node.name + " is not a numeric input. It has no function 'get_absolute_value'.", n)
		return false
	
	if not node.has_method("init"):
		Logger.error("Node " + node.name + " is not a numeric input. It has no function 'init'.", n)
		return false
	
	return true


static func assert_numeric_output(node:Node):
	assert(must_be_numeric_output("",node))
# set_percentage should only be called with values between 0.0 and 1.0.
# formatter should take a float and return a readable String from it.
# Other init values can be used to put labels onto the device.
# Must implement this
#func init(formatter:Callable, min_value = 0, max_value = 100, unit:String = "%"):
#	pass
#
#func set_percentage(p): 
#	pass
static func must_be_numeric_output(n, node:Node) -> bool:
	if node == null:
		Logger.error("Node is not a numeric output. It is null.", n)
		return false
	
	if not node.has_method("set_percentage"):
		Logger.error("Node " + node.name + " is not a numeric output. It has no function 'set_percentage'.", n)
		return false
	
	if not node.has_method("set_absolute_value"):
		Logger.error("Node " + node.name + " is not a numeric output. It has no function 'set_absolute_value'.", n)
		return false
	
	if not node.has_method("init"):
		Logger.error("Node " + node.name + " is not a numeric output. It has no function 'init'.", n)
		return false
	return true


static func assert_category_input(node:Node):
	assert(must_be_category_input("",node))
	
# get_category should only ever return values that were passed as categories via init.
# Must implement this. 
#signal category_changed
#func init(formatter:Callable, categories:Array):
#	pass
#
#func get_category(c): 
#	return 0
static func must_be_category_input(n, node:Node) -> bool:
	if node == null:
		Logger.error("Node is not a category input. It is null.", n)
		return false
	
	if not node.has_method("get_category"):
		Logger.error("Node " + node.name + " is not a category input. It has no function 'get_category'.", n)
		return false
	
	if not node.has_method("init"):
		Logger.error("Node " + node.name + " is not a category input. It has no function 'init'.", n)
		return false
	
	if not node.has_signal("category_changed"):
		Logger.error("Node " + node.name + " is not a category input. It has no signal 'category_changed'.", n)
		return false
	
	return true

static func assert_category_output(node:Node):
	assert(must_be_category_output("",node))
	
# set_category should only be called with values that were passed as categories via init.
# formatter should take a category and return a readable String from it.
# Must implement this. 
#func init(formatter:Callable, categories:Array):
#	pass
#
#func set_category(c): 
#	pass
static func must_be_category_output(n, node:Node) -> bool:
	if node == null:
		Logger.error("Node is not a category output. It is null.", n)
		return false
	
	if not node.has_method("set_category"):
		Logger.error("Node " + node.name + " is not a category output. It has no function 'set_category'.", n)
		return false
	
	if not node.has_method("get_category"):
		Logger.error("Node " + node.name + " is not a category output. It has no function 'get_category'.", n)
		return false
	
	if not node.has_method("init"):
		Logger.error("Node " + node.name + " is not a category output. It has no function 'init'.", n)
		return false
	return true

static func assert_plain_text_output(node:Node):
	assert(must_be_plain_text_output("",node))
	
static func must_be_plain_text_output(n, node:Node) -> bool:
	if node == null:
		Logger.error("Node is not a plain text output. It is null.", n)
		return false
	
	if not node.has_method("set_plain_text"):
		Logger.error("Node " + node.name + " is not a plain text output. It has no function 'set_plain_text'.", n)
		return false
	
	if not node.has_method("get_plain_text"):
		Logger.error("Node " + node.name + " is not a plain text output. It has no function 'get_plain_text'.", n)
		return false
	
	if not node.has_method("init"):
		Logger.error("Node " + node.name + " is not a plain text output. It has no function 'init'.", n)
		return false
	return true

static func assert_hit_button(node:Node):
	assert(must_be_hit_button("",node))
	
# Must implement this. 
#signal shoot
static func must_be_hit_button(n, node:Node) -> bool:
	if node == null:
		Logger.error("Node is not a hit button. It is null.", n)
		return false
	
	if not node.has_signal("hit"):
		Logger.error("Node " + node.name + " is not a hit button. It has no signal 'hit'.", n)
		return false
	return true

	# hit button
	# hold button -> zustand abfragen
	
	# String output

static func assert_string_input(node:Node):
	assert(must_be_string_input("",node))
	
static func must_be_string_input(n, node:Node) -> bool:
	if node == null:
		Logger.error("Node is not a percentage output. It is null.", n)
		return false
		
	if not node.has_signal("category_changed"):
		Logger.error("Node " + node.name + " is not a category input. It has no signal 'category_changed'.", n)
		return false
	return true

static func assert_energy_consumer_container(node:Node):
	assert(must_be_energy_consumer_container("",node))
	
static func must_be_energy_consumer_container(n, node:Node) -> bool:
	if node == null:
		Logger.error("Node is not an energy consumer contaner. It is null.", n)
		return false

	if not node.has_method("get_energy_consumer"):
		Logger.error("Node " + node.name + " is not an  energy consumer container. It has no method 'get_energy_consumer'.", n)
		return false
	
	return true

static func assert_image_output(node:Node):
	assert(must_be_image_output("",node))

static func must_be_image_output(n, node:Node) -> bool:
	if node == null:
		Logger.error("Node is not an image output. It is null.", n)
		return false
		
	if not node.has_method("set_image"):
		Logger.error("Node " + node.name + " is not an image output. It has no method 'set_image'.", n)
		return false
	return true

static func assert_range_output(node:Node):
	assert(must_be_range_output("",node))
	
static func must_be_range_output(n, node:Node) -> bool:
	if node == null:
		Logger.error("Node is not a range output. It is null.", n)
		return false
	
	if not node.has_method("set_percentage"):
		Logger.error("Node " + node.name + " is not a range output. It has no function 'set_percentage'.", n)
		return false
	
	if not node.has_method("set_range_percentage"):
		Logger.error("Node " + node.name + " is not a range output. It has no function 'set_range_percentage'.", n)
		return false
	
	if not node.has_method("init"):
		Logger.error("Node " + node.name + " is not a range output. It has no function 'init'.", n)
		return false
	return true
