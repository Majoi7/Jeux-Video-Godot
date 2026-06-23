extends Area2D

signal level_finished

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	sprite.texture = load("res://ressource/Items/Checkpoints/End/End (Idle).png")
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	level_finished.emit()
	var level := get_tree().current_scene
	if level.has_method("complete_level"):
		level.complete_level()
