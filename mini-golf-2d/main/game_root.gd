extends Node


@onready var hud: HUD = $HUDLayer/HUD
@onready var player: Player = $Player


func _ready() -> void:
	hud.reset_swing_hud()
	hud.show_swing_hud()


func _physics_process(_delta: float) -> void:
	hud.update_player_info(player.get_hud_data())
