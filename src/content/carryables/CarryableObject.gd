extends Useable
class_name Carryable

signal picked_up
signal placed_down

var is_carried := false
var is_preview := false
var disable_for_demo := false
var mesh_container

@export var carry_offset_position := Vector3.ZERO
@export var carry_sitting_offset_position := Vector3.ZERO
@export var carry_offset_rotation := Vector3.ZERO
@export var carry_sitting_offset_rotation := Vector3.ZERO


func _ready():
	mesh_container = get_node_or_null("Mesh")
	if disable_for_demo:
		$CollisionShape3D.set_deferred("disabled", true)
	if is_preview:
		collision_layer = 0
		collision_mask = 64
	else:
		collision_layer = 64
		collision_mask = 0


func pick_up(player):
	player.pick_up_item(self)
	highlightStop()
	set_is_carried(true)
	block_input = true
	picked_up.emit()


func set_is_carried(c:bool):
	is_carried = c


func is_carrying(target_position:Vector3, target_rotation:Vector3, head_rot:Vector3,  delta:float):
	if combination_object:
		return
	global_position = lerp(global_position, target_position, delta*10.0)
	position += carry_offset_position
	#target_rotation += carry_offset_rotation
	rotation.x = lerp_angle(rotation.x, carry_offset_rotation.x + target_rotation.x, delta*20.0)
	rotation.y = lerp_angle(rotation.y, carry_offset_rotation.y + target_rotation.y, delta*20.0)
	rotation.z = lerp_angle(rotation.z, carry_offset_rotation.z + target_rotation.z, delta*20.0)


func is_carrying_seated(target_position:Vector3, target_rotation:Vector3, head_rot:Vector3,  delta:float):
	if combination_object:
		return
	global_position = lerp(global_position, target_position, delta*10.0)
	position += carry_sitting_offset_position
	target_rotation += carry_sitting_offset_rotation
	rotation.x = lerp_angle(rotation.x, target_rotation.x, delta*20.0)
	rotation.y = lerp_angle(rotation.y, target_rotation.y, delta*20.0)
	rotation.z = lerp_angle(rotation.z, target_rotation.z, delta*20.0)


func in_hand():
	if mesh_container:
		mesh_container.set_shadows_off()


func in_world():
	if mesh_container:
		mesh_container.set_shadows_on()


func try_use(_player, other_object:Useable):
	if other_object and other_object.can_combine(self):
		other_object.combine(_player, self)


var combination_object : Useable
func left_click(_player, other_object:Useable, delta):
	if other_object and other_object.can_combine(self):
		combination_object = other_object
		combination_object.left_click_progress(_player, self, delta)


func no_input():
	if combination_object:
		combination_object.no_input()
		combination_object = null


func try_put_down(player):
	if player.can_put_carryable_down():
		set_is_carried(false)
		if mesh_container:
			mesh_container.reset_mesh_position()
		var t := create_tween()
		t.tween_callback(func(): block_input = false).set_delay(0.25)
		collision_layer = 64
		collision_mask = 0
		player.place_carryable(self)
		placed_down.emit()


func highlightStop():
	super()
	#for m in highlightMeshes:
		#m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON


func highlightStart():
	super()
	#for m in highlightMeshes:
		#m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


func as_preview():
	is_preview = true
	set_preview_place_material(true)


func set_preview_place_material(can_place:bool):
	if can_place:
		for m in highlightMeshes:
			m.material_override = preload("res://content/carryables/placearea/preview_ok.material")
	else:
		for m in highlightMeshes:
			m.material_override = preload("res://content/carryables/placearea/preview_err.material")


func collides_with_carryable() -> bool:
	return not get_overlapping_areas().is_empty()
