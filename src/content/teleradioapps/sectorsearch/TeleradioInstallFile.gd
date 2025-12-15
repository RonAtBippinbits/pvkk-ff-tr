extends Node

func teleradio_autoinstall():
	GameWorld.add_teleradio_entertainment("Sektorheld 2", TeleradioEntry.new(
		load("res://content/teleradioapps/sectorsearch/SectorSearch.tscn"),
		{}, false))
