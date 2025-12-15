extends RefCounted

class_name PropertyCheck

var property_key:String
var expected_value = null
var comparison:Callable

func _init(line:String = ""):
	if line == "":
		Logger.error("line is not a valid property change, it is empty", "PropertyChange.init", {"line": line})
	else:
		for comparison_key in CONST.COMPARISONS:
			if line.find(comparison_key) != -1:
				var splits = line.split(comparison_key)
				property_key = splits[0]
				property_key = property_key.to_lower().strip_edges()
				expected_value = str_to_var(splits[1])
				if expected_value == null:
					expected_value = splits[1].strip_edges()
				comparison = CONST.COMPARISONS[comparison_key]
				return
		Logger.error("line is not a valid property change, unknown comparison", "PropertyChange.init", {"line": line})

func is_valid() -> bool:
	return comparison != null and expected_value != null

func fulfilled(data:Dictionary) -> bool:
	return data.has(property_key) and comparison.call(data.get(property_key), expected_value)
