extends MarginContainer

var line_target_position:float
var tween:Tween
var current_pos := 0.0

var upgrade:Upgrade:
	set(u):
		upgrade = u
		%UpgradeName.text = tr("upgrades." + upgrade.id)
		%Description.text = tr("upgrades." + upgrade.id + ".description")

var highlight:=false:
	set(h):
		highlight = h
		$Highlight.modulate.a = lerp(0.0, 1.0, current_pos)
		if h:
			$Highlight.show()
		var new_pos = 1.0 if h else 0.0
		if tween:
			tween.kill()
		tween = create_tween()
		tween.tween_method(change_pos, current_pos, new_pos, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
		if not h:
			tween.tween_callback($Highlight.hide)


func change_pos(v):
	current_pos = v
	var margin_left = round(remap(v, 0.0, 1.0, 0, 10))#10 if h else 0
	var margin_right = round(remap(v, 0.0, 1.0, 10, 0))#0 if h else 10
	add_theme_constant_override("margin_left", margin_left)
	add_theme_constant_override("margin_right", margin_right)
	$Highlight.modulate.a = lerp(0.0, 1.0, v)
	%HighlightLine.points[1].x = -20+margin_right
	%HighlightLine.points[2].x = -20+margin_right
	%HighlightLine.modulate = lerp(Color.BLACK, CONST.COL_DISPLAY_YELLOW, v)
	%HighlightLine.z_index = round(lerp(0.0, 2.0, v))#1 if h else 0
