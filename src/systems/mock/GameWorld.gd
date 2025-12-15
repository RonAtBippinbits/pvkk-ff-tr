extends Node

var teleradio_menu_contents := {}
var teleradio_entries := {}
var paused := false
var build_type := CONST.BUILD_TYPE.FULL


func initialize_teleradio_content():
	teleradio_menu_contents = {
	"Main Menu" : ["News", "Messages", "Exams", "Manuals", "Entertainment"],
	"Messages" : ["12-12-2105:  Last Warning", "10-12-2105:  Late on Duty", "04-12-2105:  Missed shot on 4-12-2105", "15-10-2488: Safe Access Request Denied"],
	#"Statistics" : [],
	"Exams" : ["Cadet", "Sergeant", "Advanced Machinist"],
	"Manuals" : ["Energy generation", "Radar and Target aquisition", "Ammunition loading", "Aiming & Shooting", "Ground Defense"],
	"Entertainment" : ["Evadotron"]
 	}

	teleradio_entries = { 
	#"Advanced Machinist" : TeleradioEntry.new(preload("res://content/teleradio2/exam/TeleradioContentExam.tscn"), {"exam_id":"advanced_mechanist"}),
	#"News" : TeleradioEntry.new(preload("res://content/teleradio2/news/TeleradioContentNews.tscn")),
	#"Statistics" : preload("res://content/teleradio2/openport/TeleradioContentOpenFirewall.tscn")
	#"15-10-2488: Safe Access Request Denied" : TeleradioEntry.new(preload("res://content/teleradio2/messages/TeleradioContentMessage.tscn"), {"message_id":"safe_access_denied"}, true),
	}

func add_teleradio_exam(entry_name:String, entry:TeleradioEntry):
	add_teleradio_content("Exams", entry_name,entry)
	
func add_teleradio_message(entry_name:String, entry:TeleradioEntry):
	add_teleradio_content("Messages", entry_name,entry)

func add_teleradio_manual(entry_name:String, entry:TeleradioEntry):
	add_teleradio_content("Manuals", entry_name, entry)

func add_teleradio_entertainment(entry_name:String, entry:TeleradioEntry):
	add_teleradio_content("Entertainment", entry_name,entry)

func add_teleradio_content(category:String, entry_name:String, entry:TeleradioEntry):
	if teleradio_entries.has(entry_name):
		return
	if not teleradio_menu_contents.has(category):
		add_teleradio_menu_entry(category)
		teleradio_menu_contents[category] = []
	teleradio_menu_contents[category].insert(0,entry_name)
	teleradio_entries[entry_name] = entry

func add_teleradio_menu_entry(category_name:String):
	teleradio_menu_contents["Main Menu"].append(category_name)
