extends Node


signal score_increased(increase: int)
signal asteroids_cleared


const ALIEN := preload("uid://p037cuw2mek8")
const SCORE_PER_ALIEN := 300
const ASTEROID := preload("uid://cwa0eiwg4g2gs")
const ASTEROIDS_PER_ROUND := 6
const MAX_SCORE_PER_ASTEROID := 100

var asteroid_border_offset := Asteroid.get_max_radius()
var asteroids: Array[Asteroid]
var aliens: Array[Alien]

@onready var player: Player = $Player
@onready var world_center: Marker2D = $WorldCenter
@onready var world_border_curve: Curve2D = $WorldBorder.curve
@onready var world_border_length := world_border_curve.get_baked_length()


func get_player_current_health() -> int:
	return player.get_health()


func new_game() -> void:
	if not is_player_inside_world():
		add_child(player)
		player.respawn(true)
		
		for i in asteroids:
			i.queue_free()
		asteroids.clear()
		
		for i in aliens:
			i.queue_free()
		aliens.clear()
	
	for i in ASTEROIDS_PER_ROUND:
		create_new_asteroid()


func create_new_asteroid() -> void:
	var asteroid: Asteroid = ASTEROID.instantiate()
	asteroid.position = get_random_position_for_spawning(asteroid_border_offset)
	add_child(asteroid)


func get_random_position_for_spawning(border_offset := 0.0) -> Vector2:
	var random_position := world_border_curve.sample_baked(
		randf_range(0.0, world_border_length)
	)
	var distance := (random_position - world_center.position).normalized()
	
	return random_position + distance * border_offset


func _on_child_entered_tree(node: Node) -> void:
	if node is Asteroid:
		asteroids.append(node)
		
		if not node.is_connected("asteroid_hit", _on_asteroid_hit):
			node.connect("asteroid_hit", _on_asteroid_hit)
	elif node is Alien:
		aliens.append(node)
		
		if not node.is_connected("alien_hit", _on_alien_hit):
			node.connect("alien_hit", _on_alien_hit)


func _on_asteroid_hit(asteroid: Asteroid, size: int) -> void:
	if not asteroid.hit_by_alien:
		var divisor := 2 ** (size - 1)
		@warning_ignore("integer_division")
		var score_increase := MAX_SCORE_PER_ASTEROID / divisor
		score_increased.emit(score_increase)
	
	asteroids.erase(asteroid)
	if asteroids.is_empty() and size <= 1:
		asteroids_cleared.emit()


func _on_alien_hit(alien: Alien) -> void:
	score_increased.emit(SCORE_PER_ALIEN)
	aliens.erase(alien)


func _on_player_died() -> void:
	remove_child(player)


func is_player_inside_world() -> bool:
	return player.is_inside_tree()


func spawn_alien() -> void:
	var alien: Alien = ALIEN.instantiate()
	call_deferred("add_child", alien)
	
	await alien.ready
	alien.position = get_random_position_for_spawning(alien.get_width())
