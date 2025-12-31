extends Control


const MAIN_SCENE := "res://scenes/main.tscn"


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	$PlayerCPU.grab_focus()


func _on_player_cpu_pressed() -> void:
	Global.p2_type = Global.Type.CPU
	Global.change_scene(MAIN_SCENE)


func _on_player_player_pressed() -> void:
	Global.p2_type = Global.Type.PLAYER
	Global.change_scene(MAIN_SCENE)


func _on_exit_pressed() -> void:
	get_tree().quit()
