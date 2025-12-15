extends Control

var content : Node2D = null
var os : TeleradioOS
var Labels : TeleradioButtonLabels
var selected_item := 0
var selected_upgrade : Upgrade = null
var upgrade_items := []


func _process(delta):
	if not visible:
		return
	update_buttons()


func update_content():
	for c in upgrade_items:
		c.queue_free()
	upgrade_items.clear()
	
	var available_upgrades:Array= GameWorld.get_available_upgrades()
	for a in available_upgrades:
		var new_upgrade = preload("res://content/teleradio/software/os/apps/briefing/TeleradioContentSingleUpgrade.tscn").instantiate()
		new_upgrade.upgrade = a
		upgrade_items.append(new_upgrade)
		%AvailableUpgrades.add_child(new_upgrade)
	
	hide_confirmation()
	change_selection(selected_item)
	show()


func change_selection(new_selection:int):
	selected_item = clamp(new_selection, 0, upgrade_items.size()-1)
	for i in upgrade_items.size():
		upgrade_items[i].highlight = i == selected_item
	selected_upgrade = upgrade_items[selected_item].upgrade
	await(get_tree().physics_frame)
	upgrade_items[selected_item].grab_focus()
	var upgrade_name:String = tr("upgrades." + upgrade_items[selected_item].upgrade.id)
	%SelectedUpgradeLabel.text = "SELECTED: %s" % upgrade_name
	%FinalSelectedUpgradeLabel.text = upgrade_name


func reset():
	os.input.disconnect_all_buttons()
	Labels = null
	hide_confirmation()


func disconnect_up():
	os.input.disconnect_from(os.input.just_pressed_b2, pressed_up)
	Labels.label_2_visible = false

func disconnect_down():
	os.input.disconnect_from(os.input.just_pressed_b3, pressed_down)
	Labels.label_3_visible = false


func connect_content(Labels, content):
	self.content = content
	self.Labels = Labels


func update_buttons():
	os.input.connect_to(os.input.just_pressed_b1, pressed_confirm)
	
	if %ConfirmationScreen.visible:
		Labels.label_1 = "Confirm"
		Labels.label_4 = "Cancel"
		Labels.label_4_visible = true
		os.input.connect_to(os.input.just_pressed_b4, pressed_cancel)
		disconnect_up()
		disconnect_down()
	else:
		Labels.label_1 = "Continue"
		os.input.disconnect_from(os.input.just_pressed_b4, pressed_cancel)
		if selected_item > 0:
			os.input.connect_to(os.input.just_pressed_b2, pressed_up)
			Labels.label_2 = "▲"
			Labels.label_2_visible = true
		else:
			disconnect_up()
		
		if selected_item < upgrade_items.size() -1:
			os.input.connect_to(os.input.just_pressed_b3, pressed_down)
			Labels.label_3 = "▼"
			Labels.label_3_visible = true
		else:
			disconnect_down()


func pressed_up():
	change_selection(selected_item-1)


func pressed_down():
	change_selection(selected_item+1)


func pressed_confirm():
	if not %ConfirmationScreen.visible:
		show_confirmation()
	else:
		hide_confirmation()
		reset()
		content.handle_input("leave_upgrade_screen")


func pressed_cancel():
	if %ConfirmationScreen.visible:
		hide_confirmation()
		os.input.disconnect_from(os.input.just_pressed_b4, pressed_cancel)
		Labels.label_4_visible = false

func hide_confirmation():
	%ConfirmationScreen.hide()


func show_confirmation():
	$UpgradeConfirmation.play()
	var t := create_tween()
	%ConfirmationMargin.modulate.a = 0.0
	t.tween_property(%ConfirmationMargin, "modulate:a", 1.0, 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	t.set_parallel().tween_method(change_confirmation_margin, 0.0, 1.0, 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	%ConfirmationScreen.show()


func change_confirmation_margin(v):
	%ConfirmationMargin.add_theme_constant_override("margin_top", round(lerp(0.0, 56.0, v)))
