extends Control


signal clicked_screen(pos: Vector2)


const PIXELS_PER_BIRD: float = 8.0

var cursor_state := Global.CursorState.NORMAL

@onready var ammo := $Stats/ShotHud.get_children()
@onready var cursor := $Cursor
@onready var score_label := $Stats/ScoreHud/Score
@onready var round_label := $Stats/RoundHud/Label/Round
@onready var birds_killed_sprite := $Stats/HitHud/BirdsKilled
@onready var total_birds_indicator := $"Stats/HitHud/Amount of Birds"


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	hide_all_ammo()


func _process(_delta: float) -> void:
	cursor.global_position = get_global_mouse_position()
	
	if Input.is_action_just_pressed("left-click"):
		clicked_screen.emit(cursor.global_position)
	
	match cursor_state:
		Global.CursorState.NORMAL:
			set_cursor_appearance(Color("white"), 0)
		Global.CursorState.ON_SIGHT:
			set_cursor_appearance(Color("red"), 0)
		Global.CursorState.HIT:
			set_cursor_appearance(Color("red"), PI / 4)


func hide_all_ammo():
	for i in ammo:
		i.hide()


func set_cursor_appearance(color: Color, rotation_rad: float) -> void:
	cursor.modulate = color
	cursor.rotation = rotation_rad


func set_mouse_to(type: Global.CursorState) -> void:
	cursor_state = type


func set_score(score: int) -> void:
	score_label.text = str(score).lpad(6, '0')


func set_ammo(amount: int) -> void:
	hide_all_ammo()
	for i in min(amount, ammo.size()):
		ammo[i].show()


func set_round(new_round: int) -> void:
	round_label.text = str(new_round).lpad(2, '0')


func set_birds_killed(amount: int):
	const HIT_HUD_START_X: int = -23
	var total_width := PIXELS_PER_BIRD * amount
	
	birds_killed_sprite.region_rect.size.x = total_width
	birds_killed_sprite.position.x = HIT_HUD_START_X  + total_width/2


func set_total_birds(amount: int) -> void:
	const MAX_BIRD_INDICATOR_WIDTH: int = 80
	var total_width := PIXELS_PER_BIRD * amount
	
	total_birds_indicator.size.x = MAX_BIRD_INDICATOR_WIDTH  - total_width


func show_hit_cursor():
	set_mouse_to(Global.CursorState.HIT)
	await get_tree().create_timer(0.2).timeout
	set_mouse_to(Global.CursorState.NORMAL)
