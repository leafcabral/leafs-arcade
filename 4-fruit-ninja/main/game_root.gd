extends Node2D


var score := 0
var high_score := 0

@onready var background: CanvasLayer = $Background
@onready var game_world: GameWorld = $GameWorld
@onready var explosion_layer: ExplosionLayer = $ExplosionLayer
@onready var game_hud: GameHUD = $GameHUD
@onready var menu: Menu = $Menu


func _ready() -> void:
	await get_tree().create_timer(0.3).timeout
	new_game()


func new_game() -> void:
	menu.hide_menu()
	score = 0
	reset_hud()
	
	await get_tree().create_timer(1.0).timeout
	
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
	menu.show_game_over()


func _on_game_world_game_restarted() -> void:
	new_game()


func _on_game_world_bomb_sliced() -> void:
	explosion_layer.explode()
	await explosion_layer.explosion_peak
	game_world.kill_player()


func _on_menu_exit_pressed() -> void:
	explosion_layer.explode()
	await explosion_layer.explosion_peak
	get_tree().quit()


func _on_menu_continue_pressed() -> void:
	new_game()
