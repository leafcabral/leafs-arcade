extends Node

enum Type {
	PLAYER,
	CPU
}


var p2_type: Type


func clamp_position_to_screen(position: Vector2, size: Vector2, screen_size: Vector2) -> Vector2:
	var half_size := size / 2
	return position.clamp(
		Vector2.ZERO + half_size,
		screen_size - half_size
	)
	

func change_scene(url: String):
	get_tree().change_scene_to_file(url)
