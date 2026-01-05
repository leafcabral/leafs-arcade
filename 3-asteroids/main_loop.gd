extends Node2D


var score: int = 0
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


func _on_asteroid_hit(size: int) -> void:
	score += int(100.0 / 2 ** (size - 1))


func _on_child_entered_tree(node: Node) -> void:
	if node is Asteroid:
		if not node.is_connected("asteroid_hit", _on_asteroid_hit):
			node.connect("asteroid_hit", _on_asteroid_hit)
