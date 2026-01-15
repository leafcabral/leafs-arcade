extends Node


@onready var fruit_manager: FruitManager = $FruitManager


func _ready() -> void:
	fruit_manager.spawn_fruits(5)


func _on_fruit_manager_spawn_cooldown_finished() -> void:
	var fruit := fruit_manager.pool_unspawned_fruit()
	if fruit:
		add_child(fruit)
