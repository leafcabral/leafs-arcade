extends Node


@onready var hud: HUD = $HUDLayer/HUD
@onready var golf_club: GolfClub = $GolfClub


func _ready() -> void:
	hud.reset_swing_hud()
	hud.show_swing_hud()


func _physics_process(_delta: float) -> void:
	if golf_club.is_swinging:
		var data := golf_club.get_swing_data()
		if data:
			hud.set_angle(data["angle"])
			hud.set_power(data["power"])
