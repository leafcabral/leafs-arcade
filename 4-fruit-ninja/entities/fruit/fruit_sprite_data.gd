class_name FruitSpriteData
extends Resource


const FRUIT_SPRITE_DATA_PATH := &"res://entities/fruit/types/"
const BOMB_SPRITE := preload(FRUIT_SPRITE_DATA_PATH + "sprites/bomb.png")
const SPLASHES_PATH := &"res://entities/fruit/splash/"

static var normal_fruit_sprite_data: Dictionary[String, FruitSpriteData] = {}
static var fruit_splashes: Array[Texture2D]

@export var name: String
@export var full: CompressedTexture2D
@export var halfs: Array[CompressedTexture2D]
@export var splash_color: Color


static func get_all_normal() -> Dictionary[String, FruitSpriteData]:
	if normal_fruit_sprite_data.is_empty():
		for i in DirAccess.get_files_at(FRUIT_SPRITE_DATA_PATH):
			normal_fruit_sprite_data[i.get_basename()] = load(FRUIT_SPRITE_DATA_PATH + i)
	return normal_fruit_sprite_data


static func get_all_splashes() -> Array[Texture2D]:
	if fruit_splashes.is_empty():
		for i in DirAccess.get_files_at(SPLASHES_PATH):
			if i.get_extension() != "import":
				fruit_splashes.append(load(SPLASHES_PATH + i))
	return fruit_splashes


static func get_random_normal() -> FruitSpriteData:
	return get_all_normal().values().pick_random()


static func get_bomb_sprite() -> Texture2D:
	return BOMB_SPRITE


static func get_random_splash() -> Texture2D:
	return get_all_splashes().pick_random()


func get_splash_sprite() -> Sprite2D:
	var splash := Sprite2D.new()
	splash.texture = get_random_splash()
	splash.modulate = splash_color
	return splash
