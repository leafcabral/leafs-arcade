extends Node2D


const ASTEROID := preload("uid://cwa0eiwg4g2gs")

var score: int = 0
var time_elapsed := 0.0
var is_player_dead := false
var border_offset := Asteroid.get_max_radius()

@onready var hud: HUD = $HUD
@onready var world: Node = $World
@onready var player: Player = world.get_node("Player")
@onready var world_center: Marker2D = $World/WorldCenter
@onready var world_border_curve: Curve2D = $World/WorldBorder.curve
@onready var world_border_length := world_border_curve.get_baked_length()


func _ready() -> void:
	new_game()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and not is_player_dead:
		get_tree().paused = not get_tree().paused
		hud.pause_unpause()
	
	if event.is_action_pressed("ui_accept") and is_player_dead:
		world.add_child(player)
		new_game()


func _process(delta: float) -> void:
	if not get_tree().paused:
		time_elapsed += delta
	
	hud.update_health(player.get_health())
	hud.update_score(score)
	hud.update_timer(time_elapsed)


func new_game() -> void:
	score = 0
	hud.hide_death_message()
	hud.create_life_nodes(player.get_max_health())
	player.respawn(true)
	is_player_dead = false
	
	spawn_asteroid()


func spawn_asteroid() -> void:
	get_tree().call_group("Asteroids", "queue_free")
	
	var random_length := randf_range(0.0, world_border_length)
	var random_position := world_border_curve.sample_baked(random_length)
	var distance := (random_position - world_center.position).normalized()
	random_position += distance * border_offset
	
	for i in 6:
		var asteroid: Asteroid = ASTEROID.instantiate()
		asteroid.position = random_position
		world.add_child(asteroid)


func _on_player_died() -> void:
	is_player_dead = true
	hud.show_death_message()
	world.remove_child(player)


func _on_world_score_increased(increase: int) -> void:
	score += increase
