class_name HUD
extends CanvasLayer


const PLAYER_LIFE_TEXTURE_RECT: PackedScene = preload("uid://cc3pj8ggopno0")

var health_nodes: Array[TextureRect] = []
var max_health: int

@onready var score: Label = $RoundStats/Score
@onready var time: Label = $RoundStats/Time
@onready var life_container: HBoxContainer = $Lifes/Container
@onready var paused_overlay: ColorRect = $PausedOverlay
@onready var death_message: RichTextLabel = $DeathMessage
@onready var high_score_value: Label = $Lifes/HighScoreValue


func _ready() -> void:
	Global.high_score_changed.connect(
		func(value: int):
			high_score_value.text = str(value)
	)


func create_life_nodes(max_amount: int) -> void:
	max_health = max_amount
	
	for i in health_nodes:
		i.queue_free()
	health_nodes.clear()
	
	for i in max_amount:
		var health: TextureRect = PLAYER_LIFE_TEXTURE_RECT.instantiate()
		life_container.add_child(health)
		health_nodes.append(health)


func reset_hud() -> void:
	score.text = "0"
	time.text = Global.time_to_string(0)
	update_health(max_health)
	hide_death_message()


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


func pause_unpause() -> void:
	paused_overlay.visible = not paused_overlay.visible


func show_death_message() -> void:
	death_message.show()
	death_message.create_tween().tween_property(death_message, "modulate", Color("white"), 2)

func hide_death_message() -> void:
	death_message.hide()
	death_message.modulate = Color("white", 0)
