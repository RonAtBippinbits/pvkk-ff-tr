extends RefCounted
class_name TeleradioEntry

var scene: PackedScene
var seen := false


func _init(_scene:PackedScene, _context:Dictionary = {}, _seen = false):
	scene = _scene
	seen = _seen
