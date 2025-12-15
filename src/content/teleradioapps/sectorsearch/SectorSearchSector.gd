extends Node2D

signal resetted

var aim_points:PackedVector2Array = [
	Vector2(-45, -48),
	Vector2(0, -93),
	Vector2(93, 0),
	Vector2(0, 93),
	Vector2(-93, 0),
	Vector2(-45, -48),
]

func zoom(orig_pos:Vector2, pos:Vector2):
	deselect()
	var t := create_tween()
	t.set_parallel().tween_property(self, "global_position", pos, 0.4).from(orig_pos).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	t.tween_property(self, "scale", Vector2.ONE*2.0, 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	t.tween_property(self, "modulate:a", 0.0, 0.6).set_delay(0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	t.tween_callback(kill).set_delay(0.4)


func kill():
	resetted.emit()
	create_tween().tween_callback(queue_free).set_delay(0.5)


func reset():
	deselect()
	aim(0.0, 1.0)


func select():
	$Panel/Selection.show()


func deselect():
	aim(0.0, 1.0)
	$Panel/Selection.hide()


func aim(amount:float, max_amount:float):
	var current_aim_points:PackedVector2Array = []
	for p in aim_points:
		current_aim_points.append(p*ease(remap(clamp(amount, 0.0, max_amount), 0.0, max_amount, 1.0, 0.02), 0.5))
	%CountdownLabel.text = "%.1f" % abs(max_amount-clamp(amount, 0.0, max_amount))
	amount = max(amount-0.5, 0.0)
	%Aim.points = current_aim_points
	%Aim.modulate.a = min(amount, 1.0)
	%AimCenter.modulate.a = min(amount, 1.0)
