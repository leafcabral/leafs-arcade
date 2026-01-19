extends Node


const MINIMUM_FRUITS := 3
const MAXIMUM_FRUITS := 15

var wave := 1

@onready var player: Player = $Player
@onready var fruit_manager: FruitManager = $FruitManager
@onready var hud: CanvasLayer = $"../HUD"
@onready var player_health: HealthComponent = player.get_node("HealthComponent")


func _ready() -> void:
	start_wave()


func start_wave() -> void:
	var enemy_increase := floori(wave * 0.5)
	fruit_manager.spawn_fruits(min(MINIMUM_FRUITS + enemy_increase, MAXIMUM_FRUITS))


func _on_fruit_manager_spawn_cooldown_finished() -> void:
	var fruit := fruit_manager.pool_unspawned_fruit()
	if fruit:
		add_child(fruit)


func _on_fruit_manager_fruits_depleted() -> void:
	wave += 1
	
	await get_tree().create_timer(2.0).timeout
	start_wave()


func _on_fruit_manager_unsliced_fruit_left() -> void:
	player_health.damage()
	hud.set_misses(player_health.get_available())
