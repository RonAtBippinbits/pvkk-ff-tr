extends Label

@export var speed := 60.0
var finished := false
var start_y

func _ready():
	start_y = position.y

func _process(delta):
	position.y -= speed * delta
	if !finished && position.y + size.y < 0:
		finished = true
		reset_crawl()
		crawl_finished()

func crawl_finished():
	print("text done")

func reset_crawl():
	position.y = start_y
	finished = false
