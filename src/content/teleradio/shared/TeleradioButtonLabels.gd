@tool
extends Node2D
class_name TeleradioButtonLabels

@export var label_1_visible := true: set = set_label_1_visible
@export var label_1 := "Select": set = set_text_1
@export var label_2_visible := true: set = set_label_2_visible
@export var label_2 := "▲": set = set_text_2
@export var label_3_visible := true: set = set_label_3_visible
@export var label_3 := "▼": set = set_text_3
@export var label_4_visible := true: set = set_label_4_visible
@export var label_4 := "Back": set = set_text_4

@onready var labels := [
	%Option1Text, %Option2Text, %Option3Text, %Option4Text
]

func _ready():
	set_text_1(label_1)
	set_label_1_visible(label_1_visible)
	set_text_2(label_2)
	set_label_2_visible(label_2_visible)
	set_text_3(label_3)
	set_label_3_visible(label_3_visible)
	set_text_4(label_4)
	set_label_4_visible(label_4_visible)

func hide_all():
	for l in labels:
		l.hide()

func set_text(id:int, text:=""):
	id = clampi(id, 1, 4)
	labels[id-1].text = text

func show_label(id:int):
	id = clampi(id, 1, 4)
	labels[id-1].show()

func hide_label(id:int):
	id = clampi(id, 1, 4)
	labels[id-1].hide()

func set_text_1(v:String):
	label_1 = v
	%Option1Text.text = v

func set_label_1_visible(v:bool):
	label_1_visible = v
	%Option1Text.visible = v

func set_text_2(v:String):
	label_2 = v
	%Option2Text.text = v

func set_label_2_visible(v:bool):
	label_2_visible = v
	%Option2Text.visible = v

func set_text_3(v:String):
	label_3 = v
	%Option3Text.text = v

func set_label_3_visible(v:bool):
	label_3_visible = v
	%Option3Text.visible = v

func set_text_4(v:String):
	label_4 = v
	%Option4Text.text = v

func set_label_4_visible(v:bool):
	label_4_visible = v
	%Option4Text.visible = v
