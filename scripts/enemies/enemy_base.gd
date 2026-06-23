extends CharacterBody2D
class_name EnemyBase

enum State { PATROL, CHASE, HURT, DEAD }

@export var patrol_distance := 80.0
@export var speed := 60.0
@export var chase_speed := 95.0
@export var damage := 1
@export var score_value := 150
@export var max_health := 1

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var wall_detector: RayCast2D = $WallDetector
@onready var floor_detector: RayCast2D = $FloorDetector
@onready var hurt_timer: Timer = $HurtTimer

var state: State = State.PATROL
var origin_x: float
var direction := -1
var health := 1
var gravity := 980.0


func _ready() -> void:
	add_to_group("enemies")
	origin_x = global_position.x
	health = max_health
	hurt_timer.timeout.connect(_on_hurt_timer_timeout)
	_setup_animations()


func _setup_animations() -> void:
	pass


func _physics_process(delta: float) -> void:
	if state == State.DEAD:
		return

	if not is_on_floor():
		velocity.y += gravity * delta

	match state:
		State.PATROL:
			_process_patrol(delta)
		State.CHASE:
			_process_chase(delta)
		State.HURT:
			velocity.x = move_toward(velocity.x, 0, speed * 3.0 * delta)

	move_and_slide()
	_update_facing()
	_update_animation()
	_try_detect_player()


func _process_patrol(_delta: float) -> void:
	velocity.x = direction * speed
	if absf(global_position.x - origin_x) >= patrol_distance:
		direction *= -1
	if wall_detector.is_colliding() or not floor_detector.is_colliding():
		direction *= -1


func _process_chase(_delta: float) -> void:
	var player := _get_player()
	if player == null:
		state = State.PATROL
		return
	direction = sign(player.global_position.x - global_position.x)
	if direction == 0:
		direction = 1
	velocity.x = direction * chase_speed


func _try_detect_player() -> void:
	if state != State.PATROL:
		return
	var player := _get_player()
	if player == null:
		return
	if absf(player.global_position.x - global_position.x) < 160.0 and absf(player.global_position.y - global_position.y) < 80.0:
		state = State.CHASE


func _get_player() -> Node2D:
	var players := get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return null
	return players[0] as Node2D


func _update_facing() -> void:
	if velocity.x != 0:
		animated_sprite.flip_h = velocity.x > 0


func _update_animation() -> void:
	if state == State.HURT:
		return
	if absf(velocity.x) > 5.0 and animated_sprite.sprite_frames.has_animation("run"):
		animated_sprite.play("run")
	elif animated_sprite.sprite_frames.has_animation("idle"):
		animated_sprite.play("idle")


func take_stomp(_player: Player) -> void:
	take_damage(max_health)


func take_damage(amount: int = 1) -> void:
	if state == State.DEAD:
		return
	health -= amount
	if health <= 0:
		_die()
		return
	state = State.HURT
	if animated_sprite.sprite_frames.has_animation("hit"):
		animated_sprite.play("hit")
	hurt_timer.start(0.35)


func _die() -> void:
	state = State.DEAD
	GameManager.add_score(score_value)
	collision_layer = 0
	collision_mask = 0
	velocity = Vector2.ZERO
	modulate.a = 0.6
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.4)
	tween.tween_callback(queue_free)


func _on_hurt_timer_timeout() -> void:
	if state == State.DEAD:
		return
	state = State.PATROL


func _on_hurtbox_body_entered(body: Node2D) -> void:
	if state == State.DEAD:
		return
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(damage, self)
