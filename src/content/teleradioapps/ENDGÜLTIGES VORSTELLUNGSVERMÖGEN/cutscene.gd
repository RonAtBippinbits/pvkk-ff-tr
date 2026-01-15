extends CanvasLayer

@export var root : Node # make sure it's assigned in main scene

@onready var prologue = $PrologueText
#epilogue text? 

@export var speed := 60.0
var finished := false
var start_y

func _ready():
	start_y = $PrologueText.position.y

func _process(delta):
	if finished:
		return
	$PrologueText.position.y -= speed * delta
	if $PrologueText.position.y + $PrologueText.size.y < 0:
		finished = true
		#reset_crawl()
		crawl_finished()

func crawl_finished():
	root.state = root.STATES.OVERWORLD

func reset_crawl_text():
	$PrologueText.position.y = start_y
	finished = false
