extends RefCounted

class_name TeleradioState

var choices:Dictionary # deprecated, but we probably need it again
var portrait:Texture # deprecated, but we need something similar again

var step_id:String
var name:String
var text:String
var idle_mood:String
var audio_filename:String # without file ending, without path
var conditions:Array[PropertyCheck] 

func conditions_fulfilled() -> bool:
	for condition in conditions:
		if not condition.fulfilled(Data.values):
			return false
	return true
