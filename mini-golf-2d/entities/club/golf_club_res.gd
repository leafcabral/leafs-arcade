class_name GolfClubType
extends Resource

@export_range(0, 90, 1, "radians_as_degrees") var minimum_angle := 0.0
@export_range(0, 90, 1, "radians_as_degrees") var maximum_angle := PI / 2
@export_range(1, 10, 0.1, "or_greater") var power := 5.0
@export var texture: Texture2D
