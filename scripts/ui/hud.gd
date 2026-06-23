extends CanvasLayer

@onready var score_label: Label = $MarginContainer/VBox/ScoreLabel
@onready var level_label: Label = $MarginContainer/VBox/LevelLabel
@onready var hearts_container: HBoxContainer = $MarginContainer/VBox/HeartsContainer

const HEART_TEXTURE := preload("res://ressource/Other/heart.png")


func _ready() -> void:
	GameManager.score_changed.connect(_on_score_changed)
	GameManager.lives_changed.connect(_on_lives_changed)
	_on_score_changed(GameManager.score)
	_on_lives_changed(GameManager.lives)
	level_label.text = "Niveau %d" % (GameManager.current_level + 1)


func _on_score_changed(new_score: int) -> void:
	score_label.text = "Score : %d" % new_score


func _on_lives_changed(new_lives: int) -> void:
	for child in hearts_container.get_children():
		child.queue_free()
	for i in GameManager.MAX_LIVES:
		var heart := TextureRect.new()
		heart.custom_minimum_size = Vector2(20, 20)
		heart.texture = HEART_TEXTURE
		heart.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		heart.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		if i >= new_lives:
			heart.modulate = Color(0.3, 0.3, 0.3, 0.8)
		hearts_container.add_child(heart)
