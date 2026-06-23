extends Control

@onready var grid: GridContainer = $VBoxContainer/GridContainer
@onready var back_button: Button = $VBoxContainer/BackButton


func _ready() -> void:
	back_button.pressed.connect(func(): GameManager.go_to_main_menu())
	for key in GameManager.CHARACTERS.keys():
		var data: Dictionary = GameManager.CHARACTERS[key]
		var button := Button.new()
		button.custom_minimum_size = Vector2(180, 44)
		button.text = data["name"]
		button.pressed.connect(_on_character_selected.bind(key))
		grid.add_child(button)


func _on_character_selected(key: String) -> void:
	GameManager.selected_character = key
	GameManager.go_to_level_select()
