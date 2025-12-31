extends Node


enum GameState {
	MAIN_MENU,
	PAUSED,
	RUNNING,
}
enum RoundState {
	RUNNING,
	SUCCESS,
	FAIL_TIME_OUT,
	FAIL_BULLETS,
}
enum BirdState {
	ALIVE,
	JUST_SHOT,
	DEAD,
	FLEE,
}
enum CursorState {
	NORMAL,
	ON_SIGHT,
	HIT,
}


func get_angle_quadrant(rad: float) -> int:
	var angle := fmod(rad + TAU, TAU)
	if angle < PI/2:
		return 1
	elif angle < PI:
		return 2
	elif angle < 3 * PI / 2:
		return 3
	else:
		return 4
