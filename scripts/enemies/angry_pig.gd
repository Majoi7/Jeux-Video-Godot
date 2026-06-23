extends EnemyBase

func _setup_animations() -> void:
	var folder := "res://ressource/Enemies/AngryPig"
	animated_sprite.sprite_frames = SpriteFramesBuilder.build_enemy_frames(
		folder, Vector2i(36, 30), "Idle", "Walk", "Hit"
	)
	animated_sprite.play("idle")
