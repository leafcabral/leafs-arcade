extends Node2D


var score: int = 0
var time_elapsed := 0.0
var is_player_dead := false

@onready var hud: HUD = $HUD
@onready var world: Node = $World
@onready var player: Player = world.get_node("Player")


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
	hud.hide_death_message()
	hud.create_life_nodes(player.get_max_health())
	player.respawn(true)
	is_player_dead = false


func _on_asteroid_hit(size: int) -> void:
	score += int(100.0 / 2 ** (size - 1))


func _on_child_entered_tree(node: Node) -> void:
	if node is Asteroid:
		if not node.is_connected("asteroid_hit", _on_asteroid_hit):
			node.connect("asteroid_hit", _on_asteroid_hit)


func _on_player_died() -> void:
	is_player_dead = true
	hud.show_death_message()
	world.remove_child(player)
