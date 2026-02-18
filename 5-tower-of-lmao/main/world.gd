extends Node


@onready var tower: Map = $Tower
@onready var player: Player = $Player


func _ready() -> void:
	tower.player_camera = player.get_node("CameraFollow")
	player.checkpoint_position = tower.starting_checkpoint.get_center()


func handle_player_death() -> void:
	player.die()


func _on_tower_player_activated_checkpoint(checkpoint: Checkpoint) -> void:
	player.checkpoint_position = checkpoint.get_center()


func _on_tower_player_exited_screen() -> void:
	handle_player_death()


func _on_player_died() -> void:
	handle_player_death()
