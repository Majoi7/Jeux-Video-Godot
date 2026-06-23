extends Control

@onready var grid: GridContainer = $VBoxContainer/GridContainer
@onready var back_button: Button = $VBoxContainer/BackButton


func _ready() -> void:
	back_button.pressed.connect(func(): GameManager.go_to_character_select())
	for i in GameManager.TOTAL_LEVELS:
		var button := Button.new()
		button.custom_minimum_size = Vector2(120, 40)
		button.text = "Niveau %d" % (i + 1)
		button.disabled = i >= GameManager.unlocked_levels
		button.pressed.connect(_on_level_selected.bind(i))
		grid.add_child(button)


func _on_level_selected(index: int) -> void:
	GameManager.start_level(index)
