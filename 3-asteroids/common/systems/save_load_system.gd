class_name SaveLoadSystem
extends Node


const DEFAULT_SAVE_FILE := "save.json"


static func save_data(data: Dictionary, filepath := DEFAULT_SAVE_FILE) -> bool:
	var file = FileAccess.open("user://" + filepath, FileAccess.WRITE)
	
	if file:
		file.store_line(JSON.stringify(data, "\t"))
		return true
	else:
		return false


static func load_data(filepath := DEFAULT_SAVE_FILE) -> Dictionary:
	if FileAccess.file_exists("user://" + filepath):
		var file = FileAccess.open("user://" + filepath, FileAccess.READ)
		var result = JSON.parse_string(file.get_as_text())
		if result:
			return result
	return {}
