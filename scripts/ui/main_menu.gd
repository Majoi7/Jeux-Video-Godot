extends Control

@onready var play_button: Button = $VBoxContainer/PlayButton
@onready var quit_button: Button = $VBoxContainer/QuitButton


func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	quit_button.pressed.connect(_on_quit_pressed)


func _on_play_pressed() -> void:
	GameManager.reset_run()
	GameManager.go_to_character_select()


func _on_quit_pressed() -> void:
	get_tree().quit()
