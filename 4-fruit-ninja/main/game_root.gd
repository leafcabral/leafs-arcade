extends Node2D


var main_menu := true
var score := 0
var high_score := 0
var game_over := false

@onready var background: CanvasLayer = $Background
@onready var game_world: GameWorld = $GameWorld
@onready var explosion_layer: ExplosionLayer = $ExplosionLayer
@onready var game_hud: GameHUD = $GameHUD
@onready var menu: Menu = $Menu


func _ready() -> void:
	var data := SaveLoadSystem.load_data()
	if data:
		high_score = data["high_score"]
	
	game_hud.hide()
	game_world.process_mode = Node.PROCESS_MODE_DISABLED


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and not game_over and not main_menu:
		if game_world.process_mode == Node.PROCESS_MODE_PAUSABLE:
			game_world.process_mode = Node.PROCESS_MODE_DISABLED
			menu.show_paused()
		else:
			game_world.process_mode = Node.PROCESS_MODE_PAUSABLE
			menu.hide_menu()


func new_game() -> void:
	menu.hide_menu()
	score = 0
	game_over = false
	reset_hud()
	
	await get_tree().create_timer(1.0).timeout
	
	game_world.restart()


func reset_hud() -> void:
	game_hud.reset_misses()
	game_hud.update_score(score)
	game_hud.update_high_score(high_score)


func _on_game_world_fruit_sliced() -> void:
	score += 1
	game_hud.update_score(score)
	
	if score > high_score:
		high_score = score
		game_hud.update_high_score(high_score)


func _on_game_world_player_damaged(misses: int) -> void:
	game_hud.set_misses(misses)


func _on_game_world_player_died() -> void:
	game_over = true
	menu.show_game_over()


func _on_game_world_game_restarted() -> void:
	new_game()


func _on_game_world_bomb_sliced() -> void:
	explosion_layer.explode()
	await explosion_layer.explosion_peak
	game_world.kill_player()


func _on_menu_exit_pressed() -> void:
	SaveLoadSystem.save_data({"high_score": high_score})
	explosion_layer.explode()
	await explosion_layer.explosion_peak
	get_tree().quit()


func _on_menu_continue_pressed() -> void:
	if not game_over:
		var pause_event = InputEventAction.new()
		pause_event.action = "pause"
		pause_event.pressed = true
		Input.parse_input_event(pause_event)
	else:
		new_game()


func _on_start_button_pressed_and_animated() -> void:
	main_menu = false
	game_hud.show()
	game_world.process_mode = Node.PROCESS_MODE_PAUSABLE
	new_game()
