extends CharacterBody2D
class_name Player

signal died
signal respawned

const SPEED := 180.0
const JUMP_VELOCITY := -340.0
const GRAVITY := 980.0
const INVINCIBILITY_TIME := 1.2

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var camera: Camera2D = $Camera2D
@onready var stomp_area: Area2D = $StompArea
@onready var hurt_timer: Timer = $HurtTimer

var can_double_jump := false
var has_double_jump := false
var speed_multiplier := 1.0
var is_dead := false
var is_hurt := false
var facing := 1


func _ready() -> void:
	add_to_group("player")
	_setup_character_visuals()
	camera.enabled = true
	hurt_timer.timeout.connect(_on_hurt_timer_timeout)


func _setup_character_visuals() -> void:
	var data: Dictionary = GameManager.get_character_data()
	var frames := SpriteFramesBuilder.build_player_frames(data["path"], data["frame_size"])
	animated_sprite.sprite_frames = frames
	animated_sprite.play("idle")


func setup_camera_limits(left: float, right: float, top: float, bottom: float) -> void:
	camera.limit_left = int(left)
	camera.limit_right = int(right)
	camera.limit_top = int(top)
	camera.limit_bottom = int(bottom)
	camera.limit_smoothed = true


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		can_double_jump = has_double_jump

	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED * speed_multiplier
		facing = sign(direction)
		animated_sprite.flip_h = facing < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * 2.0 * delta)

	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
		elif can_double_jump:
			velocity.y = JUMP_VELOCITY * 0.92
			can_double_jump = false
			if animated_sprite.sprite_frames.has_animation("double_jump"):
				animated_sprite.play("double_jump")
				return

	move_and_slide()
	_update_animation()
	_check_stomp_kills()


func _update_animation() -> void:
	if is_hurt:
		return
	if not is_on_floor():
		if velocity.y < 0:
			animated_sprite.play("jump")
		else:
			animated_sprite.play("fall")
	elif absf(velocity.x) > 10.0:
		animated_sprite.play("run")
	else:
		animated_sprite.play("idle")


func _check_stomp_kills() -> void:
	for body in stomp_area.get_overlapping_bodies():
		if body.is_in_group("enemies") and body.has_method("take_stomp"):
			if velocity.y > 0 and global_position.y < body.global_position.y - 4:
				body.take_stomp(self)
				velocity.y = JUMP_VELOCITY * 0.65
				GameManager.add_score(100)


func take_damage(amount: int = 1, _source: Node = null) -> void:
	if is_hurt or is_dead:
		return
	if GameManager.take_life():
		die()
		return
	is_hurt = true
	animated_sprite.play("hit")
	hurt_timer.start(INVINCIBILITY_TIME)
	velocity.y = JUMP_VELOCITY * 0.35
	velocity.x = -facing * SPEED * 0.8


func die() -> void:
	is_dead = true
	velocity = Vector2.ZERO
	collision_shape.set_deferred("disabled", true)
	died.emit()


func respawn(spawn_position: Vector2) -> void:
	global_position = spawn_position
	is_dead = false
	is_hurt = false
	velocity = Vector2.ZERO
	collision_shape.disabled = false
	can_double_jump = has_double_jump
	animated_sprite.play("idle")
	respawned.emit()


func apply_fruit_bonus(fruit_type: String) -> void:
	match fruit_type:
		"bananas":
			speed_multiplier = 1.45
			get_tree().create_timer(6.0).timeout.connect(func(): speed_multiplier = 1.0)
		"strawberry":
			GameManager.heal(1)
		"pineapple":
			has_double_jump = true
			can_double_jump = true
		"cherries":
			pass


func _on_hurt_timer_timeout() -> void:
	is_hurt = false
