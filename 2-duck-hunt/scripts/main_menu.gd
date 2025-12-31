extends Control


const BIRD_SCENE := preload("res://scenes/bird.tscn")

@onready var spawn_point: Vector2 = $BirdSpawn.position


func _ready() -> void:
	$Play.grab_focus()


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_timer_timeout() -> void:
	var new_bird := BIRD_SCENE.instantiate()
	new_bird.randomize_position(spawn_point, Vector2(100, 0))
	new_bird.connect("left_screen", _on_bird_left_screen)
	
	add_child(new_bird)


func _on_bird_left_screen(bird: Bird) -> void:
	bird.queue_free()
