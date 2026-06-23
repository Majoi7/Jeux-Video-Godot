extends Control

@onready var score_label: Label = $VBoxContainer/ScoreLabel
@onready var menu_button: Button = $VBoxContainer/MenuButton


func _ready() -> void:
	score_label.text = "Score final : %d" % GameManager.score
	menu_button.pressed.connect(func(): GameManager.go_to_main_menu())
