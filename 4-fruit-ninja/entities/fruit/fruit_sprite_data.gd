class_name FruitSpriteData
extends Resource


const FRUIT_SPRITE_DATA_PATH := &"res://entities/fruit/types/"
const BOMB_SPRITE := preload(FRUIT_SPRITE_DATA_PATH + "sprites/bomb.png")

static var normal_fruit_sprite_data: Dictionary[String, FruitSpriteData] = {}

@export var full: CompressedTexture2D
@export var halfs: Array[CompressedTexture2D]


static func get_all_normal() -> Dictionary[String, FruitSpriteData]:
	if normal_fruit_sprite_data.is_empty():
		for i in DirAccess.get_files_at(FRUIT_SPRITE_DATA_PATH):
			normal_fruit_sprite_data[i.get_basename()] = load(FRUIT_SPRITE_DATA_PATH + i)
	return normal_fruit_sprite_data


static func get_random_normal() -> FruitSpriteData:
	return get_all_normal().values().pick_random()


static func get_bomb_sprite() -> Texture2D:
	return BOMB_SPRITE
