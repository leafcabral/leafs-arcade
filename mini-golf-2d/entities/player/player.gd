class_name Player
extends Node


const DRIVER_CLUB := preload("uid://co7lprfyeuwgs")
const WOOD_CLUB := preload("uid://cllyoka27wb4x")
const WEDGE_CLUB := preload("uid://dqisdeotk3fkt")

@export var pos_reset_start := Vector2.ZERO

var available_clubs := [DRIVER_CLUB, WOOD_CLUB, WEDGE_CLUB]
var pos_reset_last := Vector2.ZERO

@onready var club: GolfClub = $Club
@onready var ball: GolfBall = $Ball


func _ready() -> void:
	ball.position = pos_reset_start
	pos_reset_last = pos_reset_start


func _input(event: InputEvent) -> void:
	if not event.is_action_type():
		return
	
	for i in 3:
		if event.is_action_pressed("change_club_" + str(i + 1)):
			club.equip(available_clubs[i])
			break
	
	if event.is_action_pressed("reset_last"):
		ball.teleport(pos_reset_last)
	if event.is_action_pressed("reset_start"):
		ball.teleport(pos_reset_start)


func _on_ball_stopped_moving() -> void:
	ball.modulate = ball.stop_color


func _on_ball_started_moving() -> void:
	if ball.global_position != pos_reset_start:
		pos_reset_last = ball.global_position
	ball.modulate = Color.WHITE
