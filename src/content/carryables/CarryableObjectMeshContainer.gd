extends Node3D

@export var mesh : MeshInstance3D
@export var meshes : Array[MeshInstance3D]

@onready var mesh_pos = mesh.position
@onready var mesh_rot = mesh.rotation

func reset_mesh_position():
	mesh.position = mesh_pos
	mesh.rotation = mesh_rot


func set_shadows_off():
	for m in meshes:
		m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


func set_shadows_on():
	for m in meshes:
		m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
