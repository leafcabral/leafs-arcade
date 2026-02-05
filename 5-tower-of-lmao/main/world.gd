extends Node

@onready var tower: Map = $Tower


func _ready() -> void:
	tower.player_camera = $Player/CameraFollow
