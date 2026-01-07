extends Node2D


const SCORE_TO_SPAWN_ALIEN := 500

var score: int = 0
var next_score_to_spawn_alien := SCORE_TO_SPAWN_ALIEN
var time_elapsed := 0.0

@onready var hud: HUD = $HUD
@onready var world: Node = $World


func _ready() -> void:
	hud.create_life_nodes(world.get_player_current_health())
	hud.reset_hud()
	
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
	if not world.is_player_inside_world():
		score = 0
		hud.reset_hud()
	
	world.new_game()


func _on_world_score_increased(increase: int) -> void:
	score += increase
	hud.update_score(score)
	
	if score >= next_score_to_spawn_alien and randf() <= 0.7:
		world.spawn_alien()
		next_score_to_spawn_alien += SCORE_TO_SPAWN_ALIEN


func _on_player_took_damage(_damage: float) -> void:
	hud.update_health(world.get_player_current_health())


func _on_player_died() -> void:
	hud.show_death_message()


func _on_world_asteroids_cleared() -> void:
	new_game()
