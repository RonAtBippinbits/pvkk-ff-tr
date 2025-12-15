extends Area3D
class_name Interactable

const HighlightMat = preload("res://content/materials/mat_highlight_overlay.tres")
const HighlightUsingMat = preload("res://content/materials/mat_highlight_using_overlay.tres")

@export var block_input := false:
	set(bi):
		if bi and isHighlighted:
			highlightStop()
		block_input = bi
@export var highlightMeshes : Array[MeshInstance3D]
@export var canHold := true
@export var stopHoldingOnMouseExit := false
@export var update_plane := false
@export var debug_view := false

@export_group("Mouse Manipulation")
@export var mouse_drag := 0.9
@export var attach_origin_to : Node3D
@export var move_grab_to_attacher := false


signal started_holding
signal is_holding
signal stopped_holding
signal clicked
signal click_up
signal click_down

var initialClickPos : Vector2
var currentMousePos : Vector2
var forceStopHold := false
var isHighlighted := false
var holding := false

var mouse_attacher : Node3D = null
var initial_position_marker : Node3D = null

@onready var viewport : Viewport = get_viewport()
@onready var cam : Camera3D = viewport.get_camera_3d()
@onready var plane : Plane


func _ready():
	create_plane()
	if debug_view:
		initial_position_marker = preload("res://content/devices/input/debug/DebugIndicator.tscn").instantiate()
		create_debug_plane_mesh()
	else:
		initial_position_marker = Marker3D.new()
	if attach_origin_to:
		attach_origin_to.add_child(initial_position_marker)
	else:
		add_child(initial_position_marker)
	if has_node("MouseAttacher"):
		mouse_attacher = $MouseAttacher


func create_debug_plane_mesh():
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(0.2, 0.2)  # Set the size of the plane

	# Create a MeshInstance3D to hold the PlaneMesh
	var plane_instance = MeshInstance3D.new()
	plane_instance.mesh = plane_mesh

	# Create a basic material (optional)
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.2, 0.5, 0.8, 0.8)  # Light blue color
	plane_instance.material_override = material
	material.cull_mode = BaseMaterial3D.CULL_DISABLED

	# Position the plane based on the normal and distance
	plane_instance.global_transform.origin = plane.normal * plane.d

	# Rotate the plane to align with the normal
	plane_instance.look_at(plane_instance.global_transform.origin + plane.normal, Vector3.UP)
	plane_instance.position = Vector3.ZERO
	add_child(plane_instance)



func create_plane():
	var point_1 = to_global(Vector3(-1.0, 0.0, -1.0))
	var point_2 = to_global(Vector3(0.1, 0.0, -0.1))
	var point_3 = to_global(Vector3(0.1, 0.0, 0.1))
	plane = Plane(point_1, point_2, point_3)


func getMouseDrag() -> float:
	return mouse_drag


func getOrigin() -> Vector3:
	if mouse_attacher:
		return mouse_attacher.global_position
	else:
		return global_position


func startHold(mousePos:Vector2, initialHitPos:Vector3):
	if attach_origin_to:
		initial_position_marker.position = attach_origin_to.to_local(initialHitPos)
	elif initial_position_marker:
		initial_position_marker.position = to_local(initialHitPos)
	started_holding.emit()
	initialClickPos = mousePos


func click(mousePos:Vector2):
	currentMousePos = mousePos
	clicked.emit()


func mouseWheelDown():
	click_down.emit()


func mouseWheelUp():
	click_up.emit()


func hold(mousePos:Vector2):
	holding = true
	currentMousePos = mousePos
	is_holding.emit()
	for mesh in highlightMeshes:
		mesh.material_overlay = HighlightUsingMat


func get_hold_position() -> Vector3:
	if move_grab_to_attacher:
		return attach_origin_to.global_position
	elif initial_position_marker:
		return initial_position_marker.global_position
	return Vector3.ZERO


func stopHold(mousePos:Vector2):
	holding = false
	stopped_holding.emit()
	currentMousePos = mousePos
	if isHighlighted:
		for mesh in highlightMeshes:
			mesh.material_overlay = HighlightMat
	else:
		for mesh in highlightMeshes:
			mesh.material_overlay = null


func vectorToMouse() -> Vector2:
	if update_plane:
		create_plane()
	var ray_result = plane.intersects_ray(cam.global_position, cam.project_ray_normal(viewport.get_mouse_position()))
	if ray_result:
		var local_res : Vector3 = to_local(ray_result)
		return Vector2(local_res.x, local_res.z)
	return Vector2.ZERO


func forceStopHolding():
	forceStopHold = true


func highlightStop():
	if block_input:
		return false
	if highlightMeshes.is_empty():
		prints("WARNING - Interactor has no Mesh for Highlight!", get_path())
		return true
	isHighlighted = false
	for mesh in highlightMeshes:
		mesh.material_overlay = null
	return true


func highlightStart():
	if highlightMeshes.is_empty():
		prints("WARNING - Interactor has no Mesh for Highlight!", get_path())
		return true
	isHighlighted = true
	if GameWorld.trailerShowFurnitureHighlights:
		for mesh in highlightMeshes:
			mesh.material_overlay = HighlightMat
	return true
