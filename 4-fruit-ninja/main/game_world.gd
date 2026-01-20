extends Node


const MINIMUM_FRUITS := 3
const MAXIMUM_FRUITS := 15

var running := true
var wave := 1
var score := 0
var high_score := 0

@onready var player: Player = $Player
@onready var fruit_manager: FruitManager = $FruitManager
@onready var hud: CanvasLayer = $"../HUD"
@onready var player_health: HealthComponent = player.get_node("HealthComponent")


func _ready() -> void:
	await get_tree().create_timer(0.3).timeout
	new_game()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept") and not running:
		running = true
		hud.hide_message(0.3)
		
		new_game()


func new_game() -> void:
	score = 0
	wave = 1
	player_health.reset_health()
	fruit_manager.clear_fruits()
	hud.reset_misses()
	hud.update_score(score)
	
	await get_tree().create_timer(1).timeout
	
	start_wave()


func start_wave() -> void:
	var enemy_increase := floori(wave * 0.5)
	fruit_manager.spawn_fruits(min(MINIMUM_FRUITS + enemy_increase, MAXIMUM_FRUITS))


func _on_fruit_manager_spawn_cooldown_finished() -> void:
	var fruit := fruit_manager.pool_unspawned_fruit()
	if fruit:
		add_child(fruit)


func _on_fruit_manager_fruits_depleted() -> void:
	if running:
		wave += 1
		
		await get_tree().create_timer(2.0).timeout
		start_wave()


func _on_fruit_manager_unsliced_fruit_left() -> void:
	if running:
		player_health.damage()
		hud.set_misses(player_health.get_available())
		
		if player_health.is_dead():
			running = false
			hud.show_game_over_message()


func _on_fruit_manager_fruit_sliced() -> void:
	if running:
		score += 1
		hud.update_score(score)
		
		if score > high_score:
			high_score = score
			hud.update_high_score(high_score)
