extends CanvasLayer

@export var root : Node # make sure it's assigned in main scene

@onready var prologue = $PrologueText
@onready var epilogue = $EpilogueText

@export var speed := 60.0
var finished := false
var start_y
var t

func _ready():
	start_y = $PrologueText.position.y

func _process(delta):
	if finished: return
	if !t: return
	t.position.y -= speed * delta
	if t.position.y + t.size.y < 0:
		crawl_finished()

func crawl_finished():
	finished = true
	if t == prologue:
		root.state = root.STATES.OVERWORLD
	elif t == epilogue:
		root.state = root.STATES.MENU

func reset_crawl_text():
	$PrologueText.position.y = start_y
	$EpilogueText.position.y = start_y
	finished = false
	if root.Battles.final_boss:
		t = epilogue
	else:
		t = prologue
