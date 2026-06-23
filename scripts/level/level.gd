extends Node2D

@export var level_index := 0
@export var level_width_tiles := 50
@export var level_height_tiles := 23
@export_file("*.txt") var map_file := ""
@export_multiline var level_map := ""

const TILE_SIZE := 16

const ENEMY_SCENES := {
	"p": preload("res://scenes/enemies/angry_pig.tscn"),
	"s": preload("res://scenes/enemies/snail.tscn"),
	"c": preload("res://scenes/enemies/chicken.tscn"),
	"b": preload("res://scenes/enemies/boss_rino.tscn"),
}

const FRUIT_SCENE := preload("res://scenes/items/fruit.tscn")
const SPIKE_SCENE := preload("res://scenes/traps/spikes.tscn")
const SAW_SCENE := preload("res://scenes/traps/saw_trap.tscn")
const FIRE_SCENE := preload("res://scenes/traps/fire_trap.tscn")
const END_SCENE := preload("res://scenes/items/level_end.tscn")
const PLAYER_SCENE := preload("res://scenes/player/player.tscn")
const HUD_SCENE := preload("res://scenes/ui/hud.tscn")

const FRUIT_TYPES := ["apple", "orange", "cherries", "bananas", "strawberry", "pineapple", "kiwi", "melon"]

@onready var tile_map: TileMap = $TileMap
@onready var entities: Node2D = $Entities

var player: Player
var spawn_point := Vector2(64, 200)
var fruit_index := 0


func _ready() -> void:
	if map_file != "" and level_map == "":
		level_map = FileAccess.get_file_as_string(map_file)
	_build_tileset()
	_spawn_level_from_map()
	_spawn_player()
	_spawn_hud()


func _build_tileset() -> void:
	var tileset := TileSet.new()
	tileset.add_physics_layer()
	tileset.set_physics_layer_collision_layer(0, 1)
	tileset.set_physics_layer_collision_mask(0, 0)

	var atlas_source := TileSetAtlasSource.new()
	atlas_source.texture = load("res://ressource/Terrain/Terrain (16x16).png")
	atlas_source.texture_region_size = Vector2i(TILE_SIZE, TILE_SIZE)
	tileset.add_source(atlas_source, 0)

	for y in 11:
		for x in 22:
			atlas_source.create_tile(Vector2i(x, y))
			var tile_data := atlas_source.get_tile_data(Vector2i(x, y), 0)
			if y >= 2:
				tile_data.add_collision_polygon(0)
				tile_data.set_collision_polygon_points(0, 0, PackedVector2Array([
					Vector2(0, 0), Vector2(TILE_SIZE, 0), Vector2(TILE_SIZE, TILE_SIZE), Vector2(0, TILE_SIZE)
				]))

	tile_map.tile_set = tileset


func _spawn_level_from_map() -> void:
	var rows := level_map.strip_edges().split("\n")
	for y in rows.size():
		var row := rows[y]
		for x in mini(row.length(), level_width_tiles):
			var cell := row[x]
			var world_pos := Vector2(x * TILE_SIZE + TILE_SIZE * 0.5, y * TILE_SIZE + TILE_SIZE * 0.5)
			match cell:
				"#":
					tile_map.set_cell(0, Vector2i(x, y), 0, Vector2i(9, 2))
				"=":
					tile_map.set_cell(0, Vector2i(x, y), 0, Vector2i(9, 3))
				"^":
					_spawn_entity(SPIKE_SCENE, world_pos)
				"*":
					_spawn_fruit(world_pos)
				"p", "s", "c", "b":
					if ENEMY_SCENES.has(cell):
						_spawn_entity(ENEMY_SCENES[cell], world_pos + Vector2(0, -4))
				"~":
					_spawn_entity(SAW_SCENE, world_pos)
				"!":
					_spawn_entity(FIRE_SCENE, world_pos)
				"E":
					_spawn_entity(END_SCENE, world_pos + Vector2(0, -8))
				"@":
					spawn_point = world_pos


func _spawn_entity(scene: PackedScene, pos: Vector2) -> void:
	var node := scene.instantiate()
	node.global_position = pos
	entities.add_child(node)


func _spawn_fruit(pos: Vector2) -> void:
	var fruit: Area2D = FRUIT_SCENE.instantiate()
	fruit.fruit_type = FRUIT_TYPES[fruit_index % FRUIT_TYPES.size()]
	fruit_index += 1
	fruit.global_position = pos
	entities.add_child(fruit)


func _spawn_player() -> void:
	player = PLAYER_SCENE.instantiate()
	player.global_position = spawn_point
	player.died.connect(_on_player_died)
	add_child(player)
	player.setup_camera_limits(0, level_width_tiles * TILE_SIZE, 0, level_height_tiles * TILE_SIZE)


func _spawn_hud() -> void:
	var hud := HUD_SCENE.instantiate()
	add_child(hud)


func _on_player_died() -> void:
	await get_tree().create_timer(1.0).timeout
	if GameManager.lives <= 0:
		get_tree().change_scene_to_file("res://scenes/ui/game_over.tscn")
	else:
		player.respawn(spawn_point)


func complete_level() -> void:
	GameManager.complete_level(level_index)
	await get_tree().create_timer(1.5).timeout
	if level_index + 1 < GameManager.TOTAL_LEVELS:
		GameManager.start_level(level_index + 1)
	else:
		get_tree().change_scene_to_file("res://scenes/ui/victory.tscn")
