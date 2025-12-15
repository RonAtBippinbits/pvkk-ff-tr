extends Node

class_name InputProcessor

signal onStart
signal onStop

var predecessor:InputProcessor
var successor:InputProcessor

var stopNamed:String 
var desiredParent:String

var stopWithPredecessor := true # defines whether this InputProcessor is stopped when the predecessor stops
var stopSuccessors := true # defines whether to stop all successors when this InputProcessor is stopped. Otherwise they'll "inherit" this InputProcessors predecessor.

var desintegrating := false
var dragging := false
var rightDown := false
var dragStart

# to which device this processor listens to
var deviceId := -1

func integrate(parentNode):
#	if parentNode is get_script():
#		Logger.error("Cannot add InputProcessors as children of other InputProcessors in the scene tree. Add them to the stage instead and let the InputSystem propagate the events correctly.", "InputProcessor.integrate", {"processor": name, "parentNode": parentNode.name})
#		return

	# set the name to be the same name as the GDScript file
	var s = get_script()
	var start = s.resource_path.rfind("/") + 1
	name = s.resource_path.substr(start, s.resource_path.length() - start - 3)

	parentNode.add_child(self)
	InputSystem.addProcessor(self)

func desintegrate():
	if name != "RootProcessor":
		InputSystem.removeProcessor(self)
		desintegrating = true

func handleStart():
	pass

func handleStop():
	pass

func becameLeaf():
	pass

func notLeaf():
	pass

func resume():
	pass

func canStop() -> bool:
	return true

func handle(event) -> bool:
	if desintegrating:
		return false
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				if left_click(event): return true
			else:
				if left_click_released(event): return true
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
				if wheel_up(event): return true
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				if wheel_down(event): return true
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if event.is_pressed():
				dragStart = event.position
				rightDown = true
				return right_click(event)
			else:
				rightDown = false
				if !dragging or event.position.distance_to(dragStart) < 5:
					return right_click_released(event)
				dragging = false
				return true
	elif event is InputEventMouseMotion:
		if rightDown and not dragging:
			dragging = true
			dragStart = event.position
			return drag_right(event)
		elif rightDown and dragging:
			return drag_right(event)
		else:
			dragging = false
			return mouse_move(event)
	elif event is InputEventKey:
		return keyEvent(event)
	
	return false

func right_click_released(_event:InputEventMouseButton) -> bool:
	return false

func right_click(_event:InputEventMouseButton) -> bool:
	return false

func left_click(_event:InputEventMouseButton) -> bool:
	return false

func left_click_released(_event:InputEventMouseButton) -> bool:
	return false

func wheel_up(_event:InputEventMouseButton) -> bool:
	return false

func wheel_down(_event:InputEventMouseButton) -> bool:
	return false

func mouse_move(_event:InputEventMouseMotion) -> bool:
	return false

func stick_move(_event:InputEventJoypadMotion) -> bool:
	return false

func drag_right(event:InputEventMouseMotion) -> bool:
	if predecessor:
		return predecessor.drag_right(event)
	return false

func keyEvent(_event) -> bool:
	return false

func pressed(event, actionName:String) -> bool:
	return InputMap.event_is_action(event, actionName) and event.pressed

func released(event, actionName:String) -> bool:
	return InputMap.event_is_action(event, actionName) and not event.pressed

func justPressed(event, actionName:String) -> bool:
	var echoes := false
	if event is InputEventKey:
		echoes = event.echo
	return not echoes and InputMap.event_is_action(event, actionName) and event.pressed

func update_mouse():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
