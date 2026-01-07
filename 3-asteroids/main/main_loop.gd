extends Node2D


var score: int = 0
var time_elapsed := 0.0

@onready var hud: HUD = $HUD
@onready var world: Node = $World


func _ready() -> void:
	hud.create_life_nodes(world.get_player_current_health())
	new_game()


func _input(event: InputEvent) -> void:
	if world.is_player_inside_world():
		if event.is_action_pressed("pause"):
			get_tree().paused = not get_tree().paused
			hud.pause_unpause()
	else:
		if event.is_action_pressed("ui_accept"):
			new_game()


func _process(delta: float) -> void:
	if not get_tree().paused:
		time_elapsed += delta
	hud.update_timer(time_elapsed)


func new_game() -> void:
	score = 0
	hud.hide_death_message()
	
	world.new_game()
	hud.reset_hud()


func _on_world_score_increased(increase: int) -> void:
	score += increase
	hud.update_score(score)


func _on_player_took_damage(_damage: float) -> void:
	hud.update_health(world.get_player_current_health())


func _on_player_died() -> void:
	hud.show_death_message()
