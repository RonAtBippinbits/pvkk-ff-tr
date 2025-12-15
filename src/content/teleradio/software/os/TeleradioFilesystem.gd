extends Node
class_name TeleradioFilesystem
## This class handles saving to and loading from the Teleradios virtual file system.
##
## An app can use the virtual filesystem to permamently saves files should have an [code]APP_ID[/code]
## defined in the main script.
## Files stored here can only contain [String] data.

const _TOS_FILESYSTEM_PATH := "user://teleradio_os/"

func _enter_tree() -> void:
	var dir := DirAccess.open(_TOS_FILESYSTEM_PATH)
	if not dir:
		DirAccess.make_dir_absolute(_TOS_FILESYSTEM_PATH)

func _get_app_name() -> String:
	return owner.get_app_name()

## Store a file under the [param file_name] with the content of [param data] as [String].
func save_file(file_name:String, data:String):
	var app_name := _get_app_name()
	if app_name == "no_app_id":
		push_error("Teleradio Filesystem: Saving File from TeleradioContent without custom APP_ID.")
	var dir := DirAccess.open(_TOS_FILESYSTEM_PATH.path_join(app_name))
	if not dir:
		DirAccess.make_dir_absolute(_TOS_FILESYSTEM_PATH.path_join(app_name))
	var file = FileAccess.open(_make_tos_path(file_name), FileAccess.WRITE)
	if FileAccess.get_open_error() == OK:
		file.store_string(data)
		file.close()

## Load a file and returns the content as a [String]. If the file is not existing or can not be read, an empty [String] is returned.
func load_file(file_name:String) -> String:
	var file = FileAccess.open(_make_tos_path(file_name), FileAccess.READ)
	if FileAccess.get_open_error() == OK:
		return file.get_as_text()
	return ""

## Delete a file.
func delete_file(file_name:String):
	var dir = DirAccess.open(_TOS_FILESYSTEM_PATH.path_join(_get_app_name()))
	var file = FileAccess.open(_make_tos_path(file_name), FileAccess.READ)
	if FileAccess.get_open_error() == OK:
		file.close()
		DirAccess.remove_absolute(_make_tos_path(file_name))

## Check if a file exists.
func file_exists(file_name:String) -> bool:
	return FileAccess.file_exists(_make_tos_path(file_name))

## List the directory of the current Apps virtual storage folder.
func list_dir_content() -> Array:
	var dir = DirAccess.open(_TOS_FILESYSTEM_PATH.path_join(_get_app_name()))
	var filenames := []
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				filenames.append(file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	return filenames


func _make_tos_path(file_name:String) -> String:
	return _TOS_FILESYSTEM_PATH.path_join(_get_app_name()).path_join(file_name)
