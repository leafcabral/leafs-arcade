extends CanvasLayer


const PLAYER_LIFE_TEXTURE_RECT: PackedScene = preload("uid://cc3pj8ggopno0")

var health_nodes: Array[TextureRect] = []

@onready var score: Label = $RoundStats/Score
@onready var time: Label = $RoundStats/Time
@onready var life_container: HBoxContainer = $Lifes/Container


func create_life_nodes(max_amount: int) -> void:
	for i in health_nodes:
		i.queue_free()
	health_nodes.clear()
	
	for i in max_amount:
		var health: TextureRect = PLAYER_LIFE_TEXTURE_RECT.instantiate()
		life_container.add_child(health)
		health_nodes.append(health)


func update_health(new_health: int) -> void:
	for i in health_nodes.size():
		if i < new_health:
			health_nodes[i].modulate = Color.WHITE
		else:
			health_nodes[i].modulate = Color(0.914, 0.0, 0.0, 0.5)


func update_score(new_score: int) -> void:
	score.text = str(new_score)


func update_timer(time_seconds: float) -> void:
	time.text = Global.time_to_string(time_seconds)
