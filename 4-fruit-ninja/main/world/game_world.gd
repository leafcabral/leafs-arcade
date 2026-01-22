class_name GameWorld
extends Node


signal fruit_sliced
signal bomb_sliced
signal player_damaged(misses: int)
signal player_died

var running := true
var wave := 1

@onready var player: Player = $Player
@onready var fruit_manager: FruitManager = $FruitManager
@onready var player_health: HealthComponent = player.get_node("HealthComponent")


func restart() -> void:
	running = true
	wave = 1
	player_health.reset_health()
	fruit_manager.clear_fruits()
	
	start_wave()


func start_wave() -> void:
	var enemy_amount := FruitManager.MINIMUM_FRUITS + floori(wave * 0.5)
	fruit_manager.spawn_fruits(enemy_amount, wave > 1)


func kill_player() -> void:
	var damage := player_health.max_health
		
	player_health.damage(damage)
	player_damaged.emit(damage)
	
	running = false
	player_died.emit()


func _on_fruit_manager_fruits_depleted() -> void:
	if running:
		wave += 1
		
		await get_tree().create_timer(2.0).timeout
		start_wave()


func _on_fruit_manager_unsliced_fruit_left() -> void:
	if running:
		player_health.damage()
		player_damaged.emit(int(player_health.get_available()))
		
		if player_health.is_dead():
			running = false
			player_died.emit()


func _on_fruit_manager_fruit_sliced() -> void:
	if running:
		fruit_sliced.emit()


func _on_fruit_manager_bomb_sliced() -> void:
	if running:
		running = false
		bomb_sliced.emit()
