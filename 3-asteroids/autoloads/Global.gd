extends Node


signal high_score_changed(new_hs)
signal difficulty_changed(new_difficulty)


enum GameDifficulty {
	EASY = 0,
	MEDIUM = 1,
	HARD = 2,
	EXTREME= 3,
}


var high_score := 0:
	set(value):
		high_score = value
		high_score_changed.emit(high_score)
var difficulty := GameDifficulty.MEDIUM:
	set(value): 
		difficulty = value
		difficulty_changed.emit(difficulty)


func _ready() -> void:
	var previous_data := SaveLoadSystem.load_data()
	if previous_data:
		difficulty = previous_data["difficulty"]
		high_score = previous_data["high_score"]


func time_to_string(time: float, hanging_zero := true, show_ms := false, ommit_hours := true) -> String:
	var seconds := int(time)
	var milliseconds := time - seconds
	
	@warning_ignore("integer_division")
	var hours := seconds / 3600
	seconds %= 3600
	@warning_ignore("integer_division")
	var minutes := seconds / 60
	seconds %= 60

	var format := "%02d:%02d"
	var values := [minutes, seconds]
	if not ommit_hours or hours:
		format = "%02d:" + format
		values.push_front(hours)
	if show_ms:
		format += ".%02d"
		values.push_back(milliseconds)
	if not hanging_zero:
		format = format.remove_chars("02")
	
	return format % values


func apply_groups(from: Node, to: Node) -> void:
	for i in from.get_groups():
		to.add_to_group(i)


func get_scene_node() -> Node:
	return get_tree().current_scene
