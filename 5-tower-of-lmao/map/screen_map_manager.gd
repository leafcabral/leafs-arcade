class_name ScreenMapManager
extends Node2D


signal player_exited_screen

@export var player_camera: Camera2D

var screens: Array[ScreenMap]
var current_screen: ScreenMap
var current_checkpoint: Checkpoint


func _ready() -> void:
	var all_screens := find_children("*", "ScreenMap")
	var all_checkpoints := find_children("*", "Checkpoint")
	for i in all_screens:
		i.player_entered.connect(_on_screen_area_player_entered)
		i.player_left.connect(_on_screen_map_player_left)
	for i in all_checkpoints:
		i.player_entered.connect(_on_checkpoint_player_entered)


func _handle_screen_change() -> void:
	if screens.is_empty():
		return
	
	var last_entered_screen := screens[0]
	
	if current_screen != last_entered_screen:
		var screen_rect := last_entered_screen.get_global_rect()
		
		player_camera.limit_top = screen_rect.position.y
		player_camera.limit_left = screen_rect.position.x
		player_camera.limit_bottom = screen_rect.end.y
		player_camera.limit_right = screen_rect.end.x
		
		current_screen = last_entered_screen


func _on_screen_area_player_entered(area: ScreenMap) -> void:
	screens.append(area)
	_handle_screen_change()


func _on_screen_map_player_left(area: ScreenMap) -> void:
	screens.erase(area)
	
	if screens.is_empty():
		player_exited_screen.emit()
	
	_handle_screen_change()


func _on_checkpoint_player_entered(checkpoint: Checkpoint) -> void:
	current_checkpoint = checkpoint
