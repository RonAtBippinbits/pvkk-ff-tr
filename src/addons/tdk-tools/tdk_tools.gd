@tool
extends EditorPlugin

const SCAN_DIRS := ["res://content/teleradioapps/"]
const HELPER_GUI_SCENE = preload("res://addons/tdk-tools/TeleradioContentSafeSpace.tscn")
const TR_BUTTON_LABELS_SCENE = preload("res://content/teleradio/shared/TeleradioButtonLabels.tscn")

var config: TdkToolsSettings
var runbar: Node
var top_parent :Node
var main_panel:Node
var bottom_panel:Node
var content_select_dropdown: OptionButton
var all_scenes := []
var helper_gui : Node
var toolbar_panel : HBoxContainer
var show_helper_gui_button : CheckButton

func resize_icon(t:CompressedTexture2D, w:int, h:int) -> Texture:
	var image = t.get_image()
	image.resize(w, h, Image.INTERPOLATE_NEAREST)
	return ImageTexture.create_from_image(image)

func _enter_tree() -> void:
	add_top_menu()
	add_toolbar_menu()
	add_bottom_menu()
	scene_changed.connect(on_editor_scene_changed)

func add_top_menu():
	# Load or create config
	if not ResourceLoader.exists(TdkConst.TDK_TOOLS_CONFIG_PATH):
		config = TdkToolsSettings.new()
		ResourceSaver.save(config, TdkConst.TDK_TOOLS_CONFIG_PATH)
	else:
		config = load(TdkConst.TDK_TOOLS_CONFIG_PATH)
		
	main_panel = PanelContainer.new()
	var main_hbox = HBoxContainer.new()
	main_panel.add_child(main_hbox)
	
	add_control_to_container(CONTAINER_TOOLBAR, main_panel)
	
	# Find the runbar object
	top_parent = main_panel.get_parent()
	runbar = top_parent.get_child(4)
	runbar.connect("play_pressed", on_play_pressed)
	
	#reporder
	main_panel.get_parent().move_child(main_panel,4)
	
	# Create play mode dropdown
	content_select_dropdown = OptionButton.new()
	content_select_dropdown.tooltip_text = "Teleradio content to start"
	content_select_dropdown.item_selected.connect(on_play_mode_selected)
	main_hbox.add_child(content_select_dropdown)
	refresh_dropdown_scenes()
	
	# Create run from menu button
	var run_from_menu = Button.new()
	run_from_menu.icon = preload("res://addons/tdk-tools/RunFromMenu.svg")
	run_from_menu.tooltip_text = "Run Project with last settings."
	run_from_menu.pressed.connect(on_run_from_menu_pressed)
	main_hbox.add_child(run_from_menu)
	
	var refresh_menu = Button.new()
	refresh_menu.icon = preload("res://addons/tdk-tools/RefreshMenu.svg")
	refresh_menu.tooltip_text = "Refresh List."
	refresh_menu.text = "Refresh"
	refresh_menu.pressed.connect(refresh_dropdown_scenes)
	main_hbox.add_child(refresh_menu)

func add_toolbar_menu():
	toolbar_panel = HBoxContainer.new()
	add_control_to_container(CONTAINER_CANVAS_EDITOR_MENU, toolbar_panel)
	show_helper_gui_button = CheckButton.new()
	show_helper_gui_button.text = "👁‍🗨 Teleradio Frame"
	show_helper_gui_button.button_pressed = true
	show_helper_gui_button.toggled.connect(on_show_helper_gui_button_toggled)
	toolbar_panel.add_child(show_helper_gui_button)
	var new_tr_buttons_button := Button.new()
	new_tr_buttons_button.text = "Add Teleradio Button Labels"
	new_tr_buttons_button.pressed.connect(on_tr_buttons_pressed)
	toolbar_panel.add_child(new_tr_buttons_button)

func add_bottom_menu():
	bottom_panel = PanelContainer.new()
	var audio_tool = preload("res://addons/tdk-tools/audiocheck/AudioPlayerBusCheck.tscn").instantiate()
	bottom_panel.add_child(audio_tool)
	add_control_to_bottom_panel(bottom_panel, "TDK Audio Check")

func refresh_dropdown_scenes():
	var teleradio_content_scenes := get_teleradio_content_scenes()
	content_select_dropdown.clear()
	var selected_id := 0
	var id := 0
	for scene_path in teleradio_content_scenes:
		if config.content_selected == teleradio_content_scenes[scene_path]:
			selected_id = id
		content_select_dropdown.add_item(teleradio_content_scenes[scene_path], id)
		content_select_dropdown.set_item_metadata(id, scene_path)
		id += 1
	config.content_selected = content_select_dropdown.get_item_metadata(0)
	content_select_dropdown.select(selected_id)

func get_teleradio_content_scenes() -> Dictionary:
	var scenes := []
	for dir in SCAN_DIRS:
		scenes.append_array(dir_contents(dir))
	var cleared_scenes := {}
	for scene:String in scenes:
		var temp = load(scene)
		var scene_instance = temp.instantiate()
		if scene_instance is TeleradioContent:
			cleared_scenes[scene] = scene.trim_suffix(".tscn").split("/")[-1]
		scene_instance.queue_free()
	return cleared_scenes

func dir_contents(path) -> Array:
	var paths := []
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				paths.append_array(dir_contents(path+file_name+"/"))
			else:
				if ".tscn" in file_name:
					paths.append(path+file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	return paths

func _exit_tree():
	runbar.play_pressed.disconnect(on_play_pressed)
	remove_control_from_bottom_panel(bottom_panel)
	remove_control_from_container(CONTAINER_TOOLBAR, main_panel)
	remove_control_from_container(CONTAINER_CANVAS_EDITOR_MENU, toolbar_panel)
	bottom_panel.queue_free()
	main_panel.queue_free()
	helper_gui.queue_free()
	toolbar_panel.queue_free()
	
func on_play_pressed():
	config.custom_play_pressed = false

func on_run_from_menu_pressed():
	config.custom_play_pressed = true
	var i = get_editor_interface()
	if i.is_playing_scene():
		i.stop_playing_scene()
	i.play_main_scene()

func on_play_mode_selected(index:int):
	config.content_selected = content_select_dropdown.get_item_metadata(index)

func on_editor_scene_changed(new_scene):
	if not get_tree().get_edited_scene_root() or not new_scene is TeleradioContent:
		toolbar_panel.hide()
		if helper_gui:
			helper_gui.queue_free()
			helper_gui = null
		return
	toolbar_panel.show()
	var editor_viewport: Node = get_tree().get_edited_scene_root().get_parent()
	helper_gui = HELPER_GUI_SCENE.instantiate()
	editor_viewport.add_child(helper_gui)
	helper_gui.visible = show_helper_gui_button.button_pressed

func on_show_helper_gui_button_toggled(toggled:bool):
	if helper_gui:
		helper_gui.visible = toggled

func on_tr_buttons_pressed():
	if not get_tree().get_edited_scene_root():
		return
	var new_button_labels := TR_BUTTON_LABELS_SCENE.instantiate()
	get_tree().get_edited_scene_root().add_child(new_button_labels)
	new_button_labels.owner = get_tree().get_edited_scene_root()
