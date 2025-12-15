extends HBoxContainer

var description := "":
	set(d):
		description = d
		$Description.text = d

var points := 0:
	set(p):
		points = p
		if points > 0:
			$Points.modulate = CONST.COL_DISPLAY_YELLOW
			$Points.text = "+" + str(points)
		elif points < 0:
			$Points.modulate = CONST.COL_RED
			$Points.text = str(points)
		else:
			$Points.text = ""
