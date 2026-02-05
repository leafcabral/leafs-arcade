class_name ScreenMapManager
extends Node2D


@export var player_camera: Camera2D

var current_screen: ScreenMap


func _ready() -> void:
	for i in find_children("*", "ScreenMap"):
		i.player_entered.connect(_on_screen_area_player_entered)


func _on_screen_area_player_entered(area: ScreenMap) -> void:
	var screen_rect := area.get_global_rect()
	
	player_camera.limit_top = screen_rect.position.y
	player_camera.limit_left = screen_rect.position.x
	player_camera.limit_bottom = screen_rect.end.y
	player_camera.limit_right = screen_rect.end.x
	
	current_screen = area
