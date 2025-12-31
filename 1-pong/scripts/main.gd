extends Node2D


const BALL_SCENE: PackedScene = preload("res://scenes/ball.tscn")
const EXPLOSION_SCENE: PackedScene = preload("res://scenes/explosion_effect.tscn")

var score: Dictionary[String, int] = {
	"p1": 0,
	"p2": 0
}
var winner: String = ""

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer


func _ready() -> void:
	$HUD.show_message("Game Started")
	$"Player 2".type = Global.p2_type
	new_game()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("exit"):
		Global.change_scene("res://scenes/main_menu.tscn")


func _on_ball_exited_screen() -> void:
	for ball in get_tree().get_nodes_in_group("Balls"):
		if ball.position.x > get_viewport_rect().get_center().x:
			winner = "p1"
			
			audio_stream_player.stream = load("res://assets/next_level.wav")
			audio_stream_player.play()
		else:
			winner = "p2"
			
			audio_stream_player.stream = load("res://assets/game_over.wav")
			audio_stream_player.play()
		score[winner] += 1
		$HUD.show_message(winner.to_upper() + " Scores")
		$HUD.update_player_score(score)
			
		var explosion := EXPLOSION_SCENE.instantiate()
		explosion.position = ball.position
		add_child(explosion)
		explosion.effects_finished.connect(func(): explosion.queue_free())
		
	
	new_game()


func new_game():
	for child in get_tree().get_nodes_in_group("Balls"):
		child.queue_free()
	
	var ball := BALL_SCENE.instantiate()
	ball.position = $"Initial Ball Position".position
	ball.connect("exited_screen", _on_ball_exited_screen)
	add_child(ball)
	
	var ball_direction: int
	match winner:
		"p1":
			ball_direction = 1
		"p2":
			ball_direction = -1
		_:
			ball_direction = [1, -1].pick_random()
	ball.direction.x *= ball_direction
	
	for child in get_tree().get_nodes_in_group("Paddles"):
		child.ball_follow = ball
		


func _on_hud_paused() -> void:
	get_tree().paused = true


func _on_hud_unpaused() -> void:
	get_tree().paused = false
