extends Node


@onready var tower: Map = $Tower
@onready var player: Player = $Player


func _ready() -> void:
	tower.player_camera = player.get_node("CameraFollow")


func _on_tower_player_exited_screen() -> void:
	if tower.current_checkpoint:
		player.position = tower.current_checkpoint.get_center()
	else:
		player.position = $SpawnPoint.position
