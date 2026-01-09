extends Control


var difficulties := Global.GameDifficulty.values()

@onready var play: Button = $Buttons/Play
@onready var difficulty: Button = $Buttons/Difficulty


func _ready() -> void:
	play.grab_focus()
	Global.difficulty_changed.connect(change_difficulty_label)
	change_difficulty_label(Global.difficulty)


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://main/main_loop.tscn")


func _on_difficulty_pressed() -> void:
	Global.difficulty = wrapi(
		Global.difficulty + 1,
		difficulties[0],
		difficulties[-1] + 1
	) as Global.GameDifficulty


func change_difficulty_label(new_difficulty: Global.GameDifficulty):
	difficulty.text = "DIFFICULTY: " + Global.GameDifficulty.find_key(new_difficulty)
