extends Control

@onready var retry_button: Button = $VBoxContainer/RetryButton
@onready var menu_button: Button = $VBoxContainer/MenuButton


func _ready() -> void:
	retry_button.pressed.connect(_on_retry_pressed)
	menu_button.pressed.connect(_on_menu_pressed)


func _on_retry_pressed() -> void:
	GameManager.reset_run()
	GameManager.start_level(GameManager.current_level)


func _on_menu_pressed() -> void:
	GameManager.go_to_main_menu()
