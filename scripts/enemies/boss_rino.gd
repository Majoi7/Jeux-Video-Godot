extends EnemyBase

enum BossState { INTRO, IDLE, CHARGE, HURT, DEAD }

@export var charge_speed := 220.0

var boss_state: BossState = BossState.INTRO
var charge_direction := 1


func _ready() -> void:
	max_health = 8
	damage = 2
	score_value = 1000
	patrol_distance = 120.0
	speed = 40.0
	super._ready()
	boss_state = BossState.IDLE


func _setup_animations() -> void:
	var folder := "res://ressource/Enemies/Rino"
	animated_sprite.sprite_frames = SpriteFramesBuilder.build_boss_frames(folder)
	animated_sprite.play("idle")


func _physics_process(delta: float) -> void:
	if boss_state == BossState.DEAD:
		return

	if not is_on_floor():
		velocity.y += gravity * delta

	match boss_state:
		BossState.IDLE:
			_process_idle(delta)
		BossState.CHARGE:
			_process_charge(delta)
		BossState.HURT:
			velocity.x = move_toward(velocity.x, 0, speed * 4.0 * delta)

	move_and_slide()
	_update_facing()
	_update_boss_animation()


func _process_idle(delta: float) -> void:
	state = State.PATROL
	_process_patrol(delta)
	var player := _get_player()
	if player and absf(player.global_position.x - global_position.x) < 200.0:
		_start_charge(player)


func _start_charge(player: Node2D) -> void:
	boss_state = BossState.CHARGE
	charge_direction = sign(player.global_position.x - global_position.x)
	if charge_direction == 0:
		charge_direction = 1
	get_tree().create_timer(1.2).timeout.connect(_end_charge)


func _process_charge(_delta: float) -> void:
	velocity.x = charge_direction * charge_speed
	if wall_detector.is_colliding():
		charge_direction *= -1


func _end_charge() -> void:
	if boss_state == BossState.DEAD:
		return
	boss_state = BossState.IDLE
	velocity.x = 0


func _update_boss_animation() -> void:
	if boss_state == BossState.HURT:
		return
	if boss_state == BossState.CHARGE and animated_sprite.sprite_frames.has_animation("run"):
		animated_sprite.play("run")
	elif animated_sprite.sprite_frames.has_animation("idle"):
		animated_sprite.play("idle")


func take_damage(amount: int = 1) -> void:
	if boss_state == BossState.DEAD:
		return
	health -= amount
	if health <= 0:
		boss_state = BossState.DEAD
		state = State.DEAD
		_die()
		return
	boss_state = BossState.HURT
	state = State.HURT
	if animated_sprite.sprite_frames.has_animation("hit"):
		animated_sprite.play("hit")
	hurt_timer.start(0.5)


func _on_hurt_timer_timeout() -> void:
	if boss_state == BossState.DEAD:
		return
	boss_state = BossState.IDLE
	state = State.PATROL
