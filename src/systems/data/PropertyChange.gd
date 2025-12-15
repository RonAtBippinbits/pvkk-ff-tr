extends RefCounted

class_name PropertyChange

var property_key:String
var property_key_class:String # first part of the property key
var property_key_name:String # second part of the property key
var cumulative:bool = false
var multiplicative:bool = false
var hidden:bool = false
var is_default := false

var value

func _init(line:String = ""):
	if line != "" and line.find("=") != -1:
		var splits = line.split("=")
		property_key = splits[0]
		var is_plus_cumulative = property_key.ends_with("+")
		var is_minus_cumulative = property_key.ends_with("-")
		var is_multiplicative = property_key.ends_with("*")
		if is_plus_cumulative or is_minus_cumulative:
			cumulative = true
			property_key = property_key.substr(0, property_key.length() - 1)
		elif is_multiplicative:
			multiplicative = true
			property_key = property_key.substr(0, property_key.length() - 1)
		
		property_key = property_key.to_lower().strip_edges()
		var firstDot:int = property_key.find(".")
		property_key_class = property_key.substr(0, firstDot)
		property_key_name = property_key.substr(firstDot + 1)
		
		var value_str =splits[1].strip_edges()
		if value_str.begins_with("res://"):
			value = value_str
			hidden = true
		#check hidden flag
		elif splits[1].find("/") != -1:
			var value_split = splits[1].split("/")
			value = str_to_var(value_split[0])
			if value == null:
				value = value_split[0].strip_edges()
			if value_split[1] == "h":
				hidden = true
		else:
			value = str_to_var(splits[1])
			if value == null:
				value = splits[1].strip_edges()
		if is_minus_cumulative:
			value = -value
	else:
		Logger.error("line is not a valid property change", "PropertyChange.init", {"line": line})

func apply():
	if cumulative:
		Data.apply(property_key, value + Data.of(property_key))
	elif multiplicative:
		Data.apply(property_key, value * Data.of(property_key))
	else:
		Data.apply(property_key, value)

func duplicate() -> PropertyChange:
	var p = get_script().new()
	p.property_key = property_key
	p.property_key_class = property_key_class
	p.property_key_name = property_key_name
	p.cumulative = cumulative
	p.multiplicative = multiplicative
	p.hidden = hidden
	p.value = value
	return p
