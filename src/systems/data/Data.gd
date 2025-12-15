extends Node

# BASE DATA - should never be modified, immutable
var data:Dictionary = {}
var missions:Dictionary = {"test" : {
	"title" : "Test Mission"
}}
var upgrades:Dictionary # parsed Upgrade objects by upgrade id
var ship_blueprints:Dictionary #parsed ShipBlueprint by ship id
var default_properties:Array[PropertyChange]

# TUTORIALS
var tutorials := {}

# CURRENT DATA
var values:Dictionary
var listeners := {}
var invalids := []

func load_default_data():
	data.clear()
	missions.clear()
	upgrades.clear()
	default_properties.clear()
	tutorials.clear()
	listeners.clear()
	values.clear()
	parse_data_yaml("res://gamedata.yaml")
	parse_data_yaml("res://ships.yaml")
	on_game_data_changed()


func parse_data_yaml(path:String):
	var f = FileAccess.open(path, FileAccess.READ)
	if FileAccess.get_open_error():
		Logger.error("failed to find yaml file to parse", "Data.parseDataYaml", FileAccess.get_open_error())
		return
	
	var currentIds:Array[String] = []
	var line_count := 0
	while f.get_position() < f.get_length() and not f.eof_reached():
		line_count += 1
		var line:String = f.get_line()
		if line.strip_edges().begins_with("#"):
			continue
		
		var cleaned_line = line.strip_edges()
		if cleaned_line.begins_with("-"):
			var array = _get_array(currentIds)
			var v = cleaned_line.substr(1, cleaned_line.length() - 1)
			array.append(v.strip_edges())
			continue
		
		var parts:Array = line.split(":", false, 1)
		while parts.size() > 0 and parts.back().strip_edges().length() == 0:
			parts.pop_back()
		
		if parts.is_empty():
			continue 
		
		var indentation:int = count_left_indentation(parts[0])
		var indent_offset = indentation - currentIds.size()
		var cleaned_key = parts[0].strip_edges()
		if indent_offset > 0:
			Logger.error("error parsing line " + str(line_count) + ": unexpected indentation", "Data.parseDataYaml", line)
			continue
		
		while indent_offset < 0:
			indent_offset += 1
			currentIds.pop_back()
		
		match parts.size():
			1:
				if indent_offset == 0:
					currentIds.append(cleaned_key)
				else:
					Logger.error("error parsing line " + str(line_count) + ": unexpected indentation", "Data.parseDataYaml", line)
					continue
			2:
				var key:String = parts[0].strip_edges().to_lower()
				var value:String = parts[1].strip_edges()
				var dict := _get_dictionary(currentIds)
				dict[key] = value
	
	f.close()

func on_game_data_changed():
	# parse default properties
	var raw_properties = data.get("default_properties", [])
	default_properties.clear()
	for raw_property:String in raw_properties:
		var property = PropertyChange.new(raw_property)
		property.is_default = true
		property.apply()
		default_properties.append(property)

func count_left_indentation(line:String) -> int:
	var count = 0.0
	for c in line:
		if c == "\t":
			count += 1.0
		elif c== " ": #4 space == 1 tab
			count += 0.25
		else:
			return floori(count)
	return floori(count)


func apply_default_properties():
	for property_change:PropertyChange in default_properties:
		property_change.apply()


func _get_dictionary(keys:Array[String]) -> Dictionary:
	var dict = data
	for k in keys:
		if not dict.has(k):
			dict[k] = {}
		dict = dict.get(k)
	return dict

func _get_array(keys:Array[String]) -> Array:
	var dict = data
	for i in keys.size() - 1:
		var key = keys[i]
		if not dict.has(key):
			dict[key] = {}
		dict = dict.get(key)
	var a = dict.get(keys.back(), [])
	dict[keys.back()] = a
	return a

func has(property:String) -> bool:
	return values.has(property)

func of(property_key:String):
	property_key = property_key.to_lower()
	if not values.has(property_key):
		Logger.error("Tried to access unknown data " + property_key)
		return null
	return values[property_key]

func ofOr(property:String, default):
	property = property.to_lower()
	return values.get(property, default)

func apply(property:String, newValue):
	property = property.to_lower()
	var oldValue = values.get(property, null)
	values[property] = newValue
	invalids.clear()
	for l in listeners.get(property, []):
		if is_instance_valid(l) and l.is_inside_tree():
			l.gameDataChanged(property, oldValue, newValue)
		else:
			invalids.append(l)
	for i in invalids:
		unlistenAll(i)

func clear(property:String):
	values.erase(property)
	listeners.erase(property)

func event(eventId:String, oldValue = null, newValue = null):
	invalids.clear()
	for l in listeners.get(eventId, []):
		if is_instance_valid(l) and l.is_inside_tree():
			l.gameDataChanged(eventId, oldValue, newValue)
		else:
			invalids.append(l)
	for i in invalids:
		unlistenAll(i)

# implement
#func gameDataChanged(property:String, old_value, new_value):
#	match property:
#		"":
#			pass
func listen(listener, property:String, immediateCallback:=false):
	# I commented this out for now, too much stuff in the output...
	#print(listener.name + " listen for "+property)
	property = property.to_lower()
	var list:Array
	if listeners.has(property):
		list = listeners[property]
	else:
		list = []
		listeners[property] = list
	
	if list.has(listener):
		Logger.error("adding listener who is already listening", "Data.listen", {"listener":listener, "property":property})
		return
	list.append(listener)
	if immediateCallback and values.has(property):
		listener.gameDataChanged(property, null, of(property))
#		calling with default might be bad, because transient properties are not initialized by gamedata
#		listener.gameDataChanged(property, default(property), of(property)) 
	if not listener.tree_exiting.is_connected(unlistenAllDeferred):
		listener.tree_exiting.connect(unlistenAllDeferred.bind(listener))

func unlistenAllDeferred(listener):
	for prop in listeners:
		call_deferred("removeListener", listeners[prop], listener)

func unlistenAll(listener):
	for prop in listeners:
		removeListener(listeners[prop], listener)

func unlisten(listener, property:String):
#	print(listener.name + " unlisten for " + property)
	property = property.to_lower()
	var list:Array = listeners.get(property, [])
	if not list.has(listener):
		Logger.error("removing listener who is not listening", "Data.unlisten", {"listener":listener, "property":property})
		return
	list.erase(listener)

func removeListener(list, listener):
	list.erase(listener)

func clearListeners():
	listeners.clear()

func changeBy(property:String, change):
	return apply(property, change + of(property))

func startCaptialized(s:String):
	return s.substr(0,1).to_upper() + s.substr(1,s.length() - 1)

func serialize() -> Dictionary:
	return values.duplicate()

func deserialize(_data:Dictionary):
	for d in _data:
		values[d] = _data[d]
