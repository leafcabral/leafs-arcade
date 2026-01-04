extends Node2D


var score := 0
var time_elapsed := 0.0

@onready var player: CharacterBody2D = $Player
@onready var hud: CanvasLayer = $HUD


func _ready() -> void:
	hud.create_life_nodes(player.get_max_health())


func _process(delta: float) -> void:
	time_elapsed += delta
	
	hud.update_health(player.get_health())
	hud.update_score(score)
	hud.update_timer(time_elapsed)
