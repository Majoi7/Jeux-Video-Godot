extends Node

signal score_changed(new_score: int)
signal lives_changed(new_lives: int)
signal level_completed(level_index: int)

const MAX_LIVES := 3
const TOTAL_LEVELS := 3

const CHARACTERS := {
	"ninja_frog": {
		"name": "Grenouille Ninja",
		"path": "res://ressource/Main Characters/Ninja Frog",
		"frame_size": Vector2i(32, 32),
	},
	"mask_dude": {
		"name": "Masque",
		"path": "res://ressource/Main Characters/Mask Dude",
		"frame_size": Vector2i(32, 32),
	},
	"pink_man": {
		"name": "Homme Rose",
		"path": "res://ressource/Main Characters/Pink Man",
		"frame_size": Vector2i(32, 32),
	},
	"virtual_guy": {
		"name": "Virtual Guy",
		"path": "res://ressource/Main Characters/Virtual Guy",
		"frame_size": Vector2i(32, 32),
	},
}

const LEVEL_PATHS := [
	"res://scenes/levels/level_1.tscn",
	"res://scenes/levels/level_2.tscn",
	"res://scenes/levels/level_3.tscn",
]

const FRUIT_SCORES := {
	"apple": 10,
	"bananas": 25,
	"cherries": 50,
	"kiwi": 15,
	"melon": 20,
	"orange": 15,
	"pineapple": 30,
	"strawberry": 40,
}

var selected_character: String = "ninja_frog"
var current_level: int = 0
var score: int = 0
var lives: int = MAX_LIVES
var unlocked_levels: int = 1


func reset_run() -> void:
	score = 0
	lives = MAX_LIVES
	score_changed.emit(score)
	lives_changed.emit(lives)


func add_score(points: int) -> void:
	score += points
	score_changed.emit(score)


func heal(amount: int = 1) -> void:
	lives = mini(lives + amount, MAX_LIVES)
	lives_changed.emit(lives)


func take_life() -> bool:
	lives -= 1
	lives_changed.emit(lives)
	return lives <= 0


func complete_level(level_index: int) -> void:
	if level_index + 1 >= unlocked_levels and level_index + 1 < TOTAL_LEVELS:
		unlocked_levels = level_index + 2
	level_completed.emit(level_index)


func get_character_data() -> Dictionary:
	return CHARACTERS.get(selected_character, CHARACTERS["ninja_frog"])


func start_level(level_index: int) -> void:
	current_level = clampi(level_index, 0, LEVEL_PATHS.size() - 1)
	get_tree().change_scene_to_file(LEVEL_PATHS[current_level])


func go_to_main_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")


func go_to_character_select() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/character_select.tscn")


func go_to_level_select() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/level_select.tscn")
