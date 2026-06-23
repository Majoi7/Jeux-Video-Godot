extends EnemyBase

func _ready() -> void:
	speed = 35.0
	chase_speed = 55.0
	patrol_distance = 60.0
	score_value = 120
	super._ready()


func _setup_animations() -> void:
	var folder := "res://ressource/Enemies/Snail"
	animated_sprite.sprite_frames = SpriteFramesBuilder.build_enemy_frames(
		folder, Vector2i(38, 24), "Idle", "Walk", "Hit"
	)
	animated_sprite.play("idle")
