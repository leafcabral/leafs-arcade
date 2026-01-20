extends Node2D


var score := 0
var high_score := 0

@onready var background: CanvasLayer = $Background
@onready var game_world: Node = $GameWorld
@onready var game_hud: GameHUD = $GameHUD


func _ready() -> void:
	await get_tree().create_timer(0.3).timeout
	new_game()


func new_game() -> void:
	score = 0
	reset_hud()
	
	game_hud.show_message("Get Ready!", 1.0)
	await get_tree().create_timer(1.0).timeout
	game_hud.hide_message(0.3)
	
	game_world.restart()


func reset_hud() -> void:
	game_hud.reset_misses()
	game_hud.update_score(score)


func _on_game_world_fruit_sliced() -> void:
	score += 1
	game_hud.update_score(score)
	
	if score > high_score:
		high_score = score
		game_hud.update_high_score(high_score)


func _on_game_world_player_damaged(misses: int) -> void:
	game_hud.set_misses(misses)


func _on_game_world_player_died() -> void:
	game_hud.show_game_over_message()


func _on_game_world_game_restarted() -> void:
	game_hud.hide_message(0.3)
	new_game()


func _on_game_world_bomb_sliced() -> void:
	game_hud.show_explosion_animation()


func _on_game_hud_explosion_finished() -> void:
	game_world.kill_player()
