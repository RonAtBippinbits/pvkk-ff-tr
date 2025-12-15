@tool
extends Control

@export var gradient : Gradient

var ignore_dirs := []
var ignore_files := []
var all_scenes := []
var audio_nodes := []
var errors := {}
var files_and_errors := {}
var error_id := 0

@onready var tree = %Tree
var root

func _ready():
	refresh_list()

func refresh_list():
	var config : TdkToolsSettings
	if ResourceLoader.exists(TdkConst.TDK_TOOLS_CONFIG_PATH):
		config = load(TdkConst.TDK_TOOLS_CONFIG_PATH)
		%FolderLineEdit.text = config.last_audio_check_path
	else:
		config = TdkToolsSettings.new()
	%EditorPanel.hide()
	for i in AudioServer.bus_count:
		(%BusOptionButton as OptionButton).add_item(AudioServer.get_bus_name(i))
	tree.clear()
	audio_nodes.clear()
	all_scenes.clear()
	errors.clear()
	files_and_errors.clear()
	root = tree.create_item()
	tree.hide_root = true
	dir_contents(config.last_audio_check_path)
	tree.set_column_title(0, "Scene / Node Path")
	tree.set_column_title(1, "Bus")
	
	var progress := 0.0
	var total = float(all_scenes.size())
	for scene_path in all_scenes:
		var scene = load(scene_path)
		var scene_instance = scene.instantiate()
		find_audio_node_children(scene_instance, scene_path, "", true)
		if last_tree_node.get_child_count() == 0:
			last_tree_node.free()
		scene_instance.queue_free()
		progress += 1.0
		%ProgressBar.value = progress / total
		%AnalyzingLabel.text = "Last: " + scene_path
		await(get_tree().process_frame)
	%Loading.hide()
	for error in errors.values():
		if not files_and_errors.has(error[0]):
			files_and_errors[error[0]] = []
		files_and_errors[error[0]].append(error[1])
	if not errors.is_empty():
		%ResultLabel.text = "⛔ %s AudioStreamPlayer(s) in %s Scene(s) using the incorrect bus!" % [errors.size(), files_and_errors.size()]
		%FixAllButton.show()
	else:
		%ResultLabel.text = "😎 all good!"
		%FixAllButton.hide()


func dir_contents(path):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				#print("Found directory: " + file_name)
				if not ignore_dirs.has(file_name):
					dir_contents(path+file_name+"/")
			else:
				if ".tscn" in file_name and not ignore_files.has((path+file_name)):
					#print("Found scene: " + path + file_name)
					all_scenes.append((path as String).path_join(file_name))
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	
	
var last_tree_node : TreeItem
func find_audio_node_children(n:Node, scene_path:String, node_path:String, main:=false):
	if main:
		last_tree_node = tree.create_item(root)
		last_tree_node.set_custom_bg_color(0, Color.MIDNIGHT_BLUE)
		last_tree_node.set_custom_bg_color(1, Color.MIDNIGHT_BLUE)
		last_tree_node.set_custom_bg_color(2, Color.MIDNIGHT_BLUE)
		last_tree_node.set_custom_color(0, Color.WHITE)
		last_tree_node.set_text(0, scene_path)
	var show_correct:bool = %ShowCorrectCheckButton.button_pressed
	for c in n.get_children():
		if not main and c.scene_file_path:
			continue
		if c is AudioStreamPlayer or c is AudioStreamPlayer2D or c is AudioStreamPlayer3D:
			if not show_correct and c.bus == TdkConst.TELERADIO_APP_BUS:
				continue
			var new_item:TreeItem= tree.create_item(last_tree_node)
			new_item.set_custom_color(0, Color.WHITE)
			new_item.set_custom_bg_color(0, Color.DARK_SLATE_GRAY)
			new_item.set_custom_bg_color(1, Color.DARK_SLATE_GRAY)
			new_item.set_custom_bg_color(2, Color.DARK_SLATE_GRAY)
			new_item.set_metadata(0, [scene_path, node_path+c.name])
			new_item.set_text(0, "▶ AudioStreamPlayer: "+node_path+c.name)
			if c.bus != TdkConst.TELERADIO_APP_BUS:
				errors[error_id] = [scene_path, node_path+c.name]
				error_id += 1
				new_item.set_text(1, "⛔ %s" % c.bus)
			else:
				new_item.set_text(1, "✅ %s" % c.bus)
			new_item.set_text_alignment(1, HORIZONTAL_ALIGNMENT_CENTER)
			
			if c.stream is AudioStreamRandomizer:
				var new_rstream_item = tree.create_item(new_item)
				new_rstream_item.set_text(0, "🔁 Randomizer")
				new_rstream_item.set_custom_color(0, Color.ALICE_BLUE)
				for i in c.stream.streams_count:
					add_audio_item(new_rstream_item, c.stream.get_stream(i))
			elif c.stream is AudioStreamWAV or c.stream is AudioStreamOggVorbis:
				add_audio_item(new_item, c.stream)
		find_audio_node_children(c, scene_path, node_path+c.name+"/")


func add_audio_item(parent:TreeItem, audiostream:AudioStream):
	var new_stream_item:TreeItem= tree.create_item(parent)
	var text = "🔊 " + audiostream.resource_path
	new_stream_item.set_text(0, text)
	new_stream_item.set_icon_max_width(0, 16)
	new_stream_item.set_custom_color(0, Color.CADET_BLUE)


func _on_tree_item_selected():
	var metadata = tree.get_selected().get_metadata(0)
	if metadata:
		selected_tree_item = tree.get_selected()
		load_audio_player(metadata)
	else:
		close_editor()
	var text:String= tree.get_selected().get_text(0)
	if "ogg" in text or "wav" in text:
		text = text.split("/")[-1]
	DisplayServer.clipboard_set(text)


@onready var preview_player = %PreviewAudioStreamPlayer
var selected_tree_item : TreeItem
func load_audio_player(metadata:Array):
	%EditorPanel.show()
	# load scene
	edited_scene = load(metadata[0]).instantiate()
	var audio_player = edited_scene.get_node(metadata[1])
	preview_player.stream = audio_player.stream
	preview_player.bus = audio_player.bus
	%BusOptionButton.selected = AudioServer.get_bus_index(audio_player.bus)
	%ScenePath.text = metadata[0]
	%NodePath.text = metadata[1]
	%PanningEditor.visible = audio_player is AudioStreamPlayer3D


func close_editor():
	selected_tree_item = null
	preview_player.stop()
	%EditorPanel.hide()


func _on_close_button_pressed():
	close_editor()


func _on_save_button_pressed():
	edit()
	edited_scene.queue_free()
	edited_scene = null
	tree.deselect_all()
	close_editor()


var edited_scene:Node = null
func edit():
	# change properties
	if preview_player.bus != TdkConst.TELERADIO_APP_BUS:
		selected_tree_item.set_text(1, "⛔ %s" % preview_player.bus)
	else:
		selected_tree_item.set_text(1, "✅ %s" % preview_player.bus)
	edited_scene.get_node(%NodePath.text).bus = preview_player.bus
	
	# save it
	var packed = PackedScene.new()
	packed.pack(edited_scene)
	ResourceSaver.save(packed, %ScenePath.text)


func _on_play_button_pressed():
	if preview_player.playing:
		preview_player.stop()
	else:
		preview_player.play()


func _on_bus_option_button_item_selected(index):
	preview_player.bus = AudioServer.get_bus_name(index)


func _on_show_correct_check_button_pressed() -> void:
	refresh_list()


func _on_refresh_button_pressed() -> void:
	refresh_list()


func _on_open_folder_button_pressed() -> void:
	%FileDialog.popup_centered(Vector2i(640, 640))


func _on_file_dialog_dir_selected(dir: String) -> void:
	var config : TdkToolsSettings
	if ResourceLoader.exists(TdkConst.TDK_TOOLS_CONFIG_PATH):
		config = load(TdkConst.TDK_TOOLS_CONFIG_PATH)
		config.last_audio_check_path = dir
	%FolderLineEdit.text = dir
	refresh_list()


func _on_fix_all_button_pressed() -> void:
	for packed_scene_path in files_and_errors:
		# load the scene
		var temp = load(packed_scene_path).instantiate()
		for audio_stream_player_path in files_and_errors[packed_scene_path]:
			pass
			temp.get_node(audio_stream_player_path).bus = TdkConst.TELERADIO_APP_BUS
		# save it
		var packed = PackedScene.new()
		packed.pack(temp)
		ResourceSaver.save(packed, packed_scene_path)
	refresh_list()
