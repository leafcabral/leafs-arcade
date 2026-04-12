@tool
class_name HUD
extends Control


@onready var power_graph: TextureProgressBar = $InfoSwing/Power/PowerGraph
@onready var power_label: Label = $InfoSwing/Power/PowerLabel
@onready var angle_graph: TextureProgressBar = $InfoSwing/Angle/AngleGraph
@onready var angle_label: Label = $InfoSwing/Angle/AngleLabel
@onready var strokes_label: Label = $InfoSwing/StrokesLabel


func _ready() -> void:
	reset_swing_hud()


func reset_swing_hud() -> void:
	power_graph.value = 0
	angle_graph.value = 0
	power_label.text = "0%"
	angle_label.text = "0°"


func hide_swing_hud() -> void:
	power_graph.hide()
	angle_graph.hide()
	power_label.hide()
	angle_label.hide()


func show_swing_hud() -> void:
	power_graph.show()
	angle_graph.show()
	power_label.show()
	angle_label.show()


func update_player_info(player_data: Dictionary) -> void:
	set_angle(player_data["angle"])
	set_power(player_data["power"])
	set_strokes(player_data["strokes"])


func set_angle(angle_rad: float) -> void:
	var angle := snappedf(rad_to_deg(angle_rad), 1)
	angle_graph.value = angle
	angle_label.text = str(int(angle)) + "°"


func set_power(power_percent: float) -> void:
	var power := snappedf(power_percent, 1)
	power_graph.value = power
	power_label.text = str(int(power)) + "%"


func set_strokes(stroke_amount: int) -> void:
	strokes_label.text = "Strokes:   " + str(stroke_amount)
