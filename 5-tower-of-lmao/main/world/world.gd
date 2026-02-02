extends Node


@export var player: Player

@onready var screen_area_manager: ScreenAreaManager = $ScreenAreaManager


func _ready() -> void:
	screen_area_manager.player_camera = player.get_node("CameraFollow")
