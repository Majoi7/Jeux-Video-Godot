extends EnemyBase

func _ready() -> void:
	speed = 75.0
	chase_speed = 110.0
	patrol_distance = 100.0
	score_value = 180
	super._ready()


func _setup_animations() -> void:
	var folder := "res://ressource/Enemies/Chicken"
	animated_sprite.sprite_frames = SpriteFramesBuilder.build_enemy_frames(
		folder, Vector2i(32, 34), "Idle", "Run", "Hit"
	)
	animated_sprite.play("idle")
