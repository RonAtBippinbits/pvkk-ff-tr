extends Control


func update_content():
	%MissionTitle.text = Data.of("mission.current").title
	%ObjectiveLabel.text = add_highlights_to_string(Data.of("mission.current").objective)
	var ammo_text := ""
	
	var ammo_properties = CONST.AMMO_ALL.map(func(x): return "ammo." + x)
	for p in Data.of("mission.current").property_changes:
		
		if p in ammo_properties:
			var ammo_amount :String = str(Data.of("mission.current").property_changes[p].value)
			if ammo_amount == "-1":
				continue
			if ammo_amount.length() == 1:
				ammo_amount = " " + ammo_amount
			var ammo_type = str(Data.of("mission.current").property_changes[p].property_key_name).to_upper()
			if ammo_text != "":
				ammo_text += "\n"
			ammo_text = ammo_amount + "x " + ammo_type
	if Data.of("combat.missiles") > 0:
		ammo_text += "\n%.0fx Defense Missiles" % Data.of("combat.missiles")
			
	%AmmunitionList.text = ammo_text
	
	var devices_text := ""
	for device in Data.of("mission.current").devices:
		if devices_text != "":
			devices_text += "\n"
		devices_text += "• " + tr(device)
	if devices_text == "":
		devices_text = "No new devices."
	%DevicesList.text = devices_text
	
	var assignment_text := ""
	for assignment in Data.of("mission.current").assignments:
		if assignment_text != "":
			assignment_text += "\n"
		assignment_text += "• " + tr(assignment.property_key) % assignment.change
	if assignment_text == "":
		assignment_text = "No assignments."
	%AssignmentsLabel.text = assignment_text
	
	show()


func add_highlights_to_string(string:String) -> String:
	var regex = RegEx.new()
	regex.compile("`([^`]+)`")
	var matches = regex.search_all(string)
	for m in matches:
		string = regex.sub(string, replace_with_color(m))
	return string

func replace_with_color(match) -> String:
	return "[color=#ffd678]" + match.strings[1] + "[/color]"
