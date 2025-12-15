extends RefCounted

class_name Upgrade

var id:String
var requirements:Array[PropertyCheck]
var effects:Array[PropertyChange]

func apply():
	for effect:PropertyChange in effects:
		effect.apply()

func all_requirements_fulfilled():
	for check:PropertyCheck in requirements:
		if not check.fulfilled(Data.values):
			return false
	return true
