extends Node2D


const BIRD_SCENE := preload("res://scenes/bird.tscn")
const ROUNDS_MAX: int = 99
const BIRDS_MAX: int = 10

var birds: Array[Bird] = []
var birds_to_spawn := 1.0
var round_num: int = 0
var score: int = 0
var round_failed := false: set = set_round_failed
var remaining_bullets: int
var birds_killed: int
var is_round_active: bool

@onready var hud_node := $HUD
@onready var bg_node := $Background
@onready var spawn_point: Vector2 = $Border/BirdSpawn.position


func _ready() -> void:
	start_new_round()


func start_new_round() -> void:
	if not round_failed and round_num:
		score += 500
	
	birds_to_spawn = min(birds_to_spawn + 0.35, BIRDS_MAX)
	round_num = min(round_num + 1, ROUNDS_MAX)
	
	reset_ammo()
	round_failed = false
	birds_killed = 0
	is_round_active = true
	
	hud_node.set_total_birds(birds_to_spawn)
	update_hud()
	
	var bird_speed_inc := round_num * 10
	for _i in floorf(birds_to_spawn):
		create_bird(bird_speed_inc)
	
	try_spawning_bird()


func reset_ammo():
	remaining_bullets = 3
	hud_node.set_ammo(remaining_bullets)


func update_hud() -> void:
	hud_node.set_ammo(remaining_bullets)
	hud_node.set_score(score)
	hud_node.set_round(round_num)
	hud_node.set_birds_killed(birds_killed)


func create_bird(speed_inc: int = 0) -> void:
	var new_bird := BIRD_SCENE.instantiate()
	
	new_bird.randomize_position(spawn_point, Vector2(200, 0))
	new_bird.speed += speed_inc
	new_bird.connect("left_screen", _on_bird_left_screen)
	
	birds.append(new_bird)


func try_spawning_bird():
	if not birds.is_empty():
		add_child(birds[0])
		reset_ammo()


func _on_hud_clicked_screen(pos: Vector2) -> void:
	if not is_round_active:
		return
	
	remaining_bullets -= 1
	hud_node.set_ammo(remaining_bullets)
	
	try_hit_bird(pos)
	if not remaining_bullets:
		stop_shooting()


func try_hit_bird(pos: Vector2) -> bool:
	var current_bird := birds[0]
	if not birds.is_empty() and current_bird.is_inside_tree():
		if current_bird.is_hittable_at(pos):
			handle_bird_hit(current_bird)
			return true
	return false


func handle_bird_hit(bird: Bird) -> void:
	birds.erase(bird)
	birds_killed += 1
	score += 100
	
	update_hud()
	bird.get_shot()
	reset_ammo()
	
	if birds.is_empty():
		is_round_active = false
	
	hud_node.show_hit_cursor()


func stop_shooting() -> void:
	is_round_active = false
	round_failed = true
	
	for bird in birds:
		if not bird.is_inside_tree():
			add_child(bird)
		bird.flee()
	
	if bg_node.can_spawn_dog():
		bg_node.spawn_dog_laugh(spawn_point.x)


func _on_bird_left_screen(bird: Bird) -> void:
	if bg_node.can_spawn_dog():
		bg_node.spawn_dog_with_bird(bird.position.x)
	bird.queue_free()
	birds.erase(bird)
	
	# TODO: Make da dawg appear
	
	if birds.is_empty() and not is_round_active:
		end_round()
	elif is_round_active:
		try_spawning_bird()


func end_round():
	is_round_active = false
	await get_tree().create_timer(1.5).timeout
	start_new_round()


func set_round_failed(is_failed: bool):
	round_failed = is_failed
	if round_failed and round_num:
		bg_node.change_bg_color(Color.ORANGE_RED)
