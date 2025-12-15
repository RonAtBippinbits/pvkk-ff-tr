extends Node

var processorsToAdd = []
var processorsToRemove = []

var doInputLogging := true

var input_helper : Node = null

func pr(s:String):
	if doInputLogging:
		print(s)

func addProcessor(processor:InputProcessor):
#	pr("add input: " + processor.name +" - "+processor.get_parent().name)
	processorsToAdd.append(processor)

func removeProcessor(processor:InputProcessor):
#	pr("stop input: " + processor.name +" - "+processor.get_parent().name)
	processorsToRemove.append(processor)

func clearProcessors():
#	possibly don't need this and istead use version below
#
#	var currentNode = getLastSuccessor()
#	while currentNode != $RootProcessor:
#		processorsToRemove.append(currentNode)
#		currentNode = currentNode.predecessor

	for input in $RootProcessor.childrenByDeviceId.values():
		processorsToRemove.append(input)

func _process(_delta):
	for p in processorsToRemove.duplicate():
		if not is_instance_valid(p) or not p.predecessor:
			processorsToRemove.erase(p)
	
	for processor in processorsToRemove:
		if processor.canStop():
			# if processor should both be stopped and started, remove it from the start list
			var index = processorsToAdd.find(processor)
			if index != -1:
				processorsToAdd.remove(index)
			
			processor.predecessor.successor = null
			var currentSuccessor = processor.successor
			var lastPredecessor = processor.predecessor
			if processor.stopSuccessors:
				while currentSuccessor != null:
					if currentSuccessor.stopWithPredecessor:
						pr("transitive stop input: " + currentSuccessor.name)
						deleteInputProcessor(currentSuccessor)
						var successorIndex = processorsToRemove.find(currentSuccessor)
						if successorIndex != -1:
							processorsToRemove.remove(successorIndex)
						currentSuccessor = currentSuccessor.successor
					else:
						currentSuccessor.predecessor = lastPredecessor
						lastPredecessor.successor = currentSuccessor
						currentSuccessor = currentSuccessor.successor

			deleteInputProcessor(processor)
		printout()
	if processorsToRemove.size() > 0 and processorsToAdd.size() == 0:
		getLastSuccessor().becameLeaf()
	processorsToRemove.clear()
	
	for processor in processorsToAdd:
		if processor.stopNamed != "":
			var split = processor.stopNamed.split(",")
			for splitName in split:
				var last = getLastSuccessor()
				if splitName == last.name or "@" + splitName in last.name:
					last.desintegrate()
					return
		if processor.desiredParent != "":
			var last = getLastSuccessor()
			if not (last.name == processor.desiredParent or "@"+processor.desiredParent in last.name):
				last.desintegrate()
				return
				
		var lastChild := getLastSuccessor()
		processor.predecessor = lastChild
		lastChild.successor = processor
		lastChild.notLeaf()
		processor.emit_signal("onStart")
		processor.handleStart()
		processor.becameLeaf()
		
		printout()
	processorsToAdd.clear()

func printout():
	if doInputLogging:
		var currentNode:InputProcessor = get_child(0)
		var out := ""
		while currentNode.successor != null:
			if out != "":
				out += " -> "
			currentNode = currentNode.successor
			out += currentNode.name
			if currentNode.deviceId != -1:
				out += "(" + str(currentNode.deviceId) + ")"
		prints("INPUT STATE:", out)

func _unhandled_input(event):
	var currentNode := getLastSuccessor()
	var handled = false
	while not handled:
#		prints(event, currentNode.name, currentNode.deviceId, getDeviceIndex(event), currentNode.deviceId == -1 or currentNode.deviceId == event.device)
		if currentNode.deviceId == -1 or currentNode.deviceId == getDeviceIndex(event):
			handled = currentNode.handle(event)

		if not handled:
			if currentNode.predecessor != null:
				currentNode = currentNode.predecessor
			else:
				handled = true

func getLastSuccessor() -> InputProcessor:
	var currentNode:InputProcessor= get_child(0)
	while currentNode.successor and is_instance_valid(currentNode.successor) and currentNode.successor.is_inside_tree():
		currentNode = currentNode.successor
	return currentNode

func deleteInputProcessor(processor):
	processor.emit_signal("onStop")
	processor.handleStop()

	if not processor.stopSuccessors and processor.successor:
		processor.successor.predecessor = processor.predecessor
		processor.predecessor.successor = processor.successor

	var parent = processor.get_parent()
	if parent:
		parent.remove_child(processor)
	processor.queue_free()

func shake(strength:float, duration:= 0.2, period:= 16.0, pos:Vector3 = Vector3.INF):
	for cam in get_tree().get_nodes_in_group("camera-shake"):
		cam.shake(strength, duration, period, pos)

func shakeTarget(target, strength:float, duration:= 0.2, period:= 16.0):
	for cam in get_tree().get_nodes_in_group("camera-shake"):
		if cam.target == target:
			cam.shake(strength, duration, period)
			return

func getCamera()->Camera2D:
	for cam in get_tree().get_nodes_in_group("cameras"):
		if cam.is_current():
			return cam
	return null

func cleanString(string:String) -> String:
	var regex = RegEx.new()
	regex.compile("[\\p{L} ]*")
	var t = ""
	var matches = regex.search_all(string)
	for m in matches:
		for s in m.strings:
			t += s
	return t

func updateLinEdit(edit, new_text):
	var t = cleanString(new_text)
	var cp = edit.caret_column - (edit.text.length() - t.length())
	edit.text = t
	edit.caret_column = clamp(cp, 0, t.length())

func grabFocusIfNone(uiElement):
	if uiElement.get_viewport().gui_get_focus_owner() == null:
		grabFocus(uiElement)
	
func grabFocus(uiElement):
	Audio.ignoreNextHover()
	if uiElement:
		uiElement.grab_focus()

func getInputDirection() -> Vector2:
	var left = Input.get_action_raw_strength("ui_left")
	var right = Input.get_action_raw_strength("ui_right")
	var up = Input.get_action_raw_strength("ui_up")
	var down = Input.get_action_raw_strength("ui_down")
	left = max(0.0, left - Options.gamepadStickDeadZone)
	right = max(0.0, right - Options.gamepadStickDeadZone)
	up = max(0.0, up - Options.gamepadStickDeadZone)
	down = max(0.0, down - Options.gamepadStickDeadZone)
	var hor = right - left
	var ver = down - up
	if Options.gamepadStickDeadZone > 0.0:
		hor *= (1.0 / (1.0 - Options.gamepadStickDeadZone))
		ver *= (1.0 / (1.0 - Options.gamepadStickDeadZone))
	var movedir = Vector2(hor, ver)
	
	if movedir.length() > 1.0:
		movedir = movedir.normalized()
	return movedir

func getDeviceIndex(event) -> int:
	var deviceId := 0
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		deviceId += 1 + event.device
	return deviceId
