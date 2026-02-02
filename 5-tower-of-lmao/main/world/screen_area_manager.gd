class_name ScreenAreaManager
extends Node


@export var player_camera: Camera2D
@export_range(0, 1, 0.01, "or_greater") var transition := 0.3

var current_screen: ScreenArea


func _ready() -> void:
	for i in find_children("*", "ScreenArea"):
		i.player_entered.connect(_on_screen_area_player_entered)


func _on_screen_area_player_entered(area: ScreenArea) -> void:
	var screen_rect := area.get_rect()
	
	var time := transition if current_screen else 0.0
	var tween := player_camera.create_tween()
	tween.tween_property(player_camera, "limit_top", screen_rect.position.y, time)
	tween.parallel().tween_property(player_camera, "limit_left", screen_rect.position.x, time)
	tween.parallel().tween_property(player_camera, "limit_bottom", screen_rect.end.y, time)
	tween.parallel().tween_property(player_camera, "limit_right", screen_rect.end.x, time)
	
	current_screen = area
