extends Node2D

@export var cycle_on_time := 1.5
@export var cycle_off_time := 1.5
@export var damage := 1

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hurtbox: Area2D = $Hurtbox
@onready var timer: Timer = $Timer

var is_active := false


func _ready() -> void:
	_build_frames()
	timer.timeout.connect(_toggle)
	timer.wait_time = cycle_off_time
	timer.start()
	hurtbox.body_entered.connect(_on_hurtbox_body_entered)
	_set_active(false)


func _build_frames() -> void:
	var on_tex: Texture2D = load("res://Free/Traps/Fire/On (16x32).png")
	var off_tex: Texture2D = load("res://Free/Traps/Fire/Off.png")
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	frames.add_animation(&"on")
	frames.set_animation_loop(&"on", true)
	frames.set_animation_speed(&"on", 10.0)
	var frame_size := Vector2i(16, 32)
	var columns := maxi(1, on_tex.get_width() / frame_size.x)
	for i in columns:
		var atlas := AtlasTexture.new()
		atlas.atlas = on_tex
		atlas.region = Rect2(i * frame_size.x, 0, frame_size.x, frame_size.y)
		frames.add_frame(&"on", atlas)
	frames.add_animation(&"off")
	frames.add_frame(&"off", off_tex)
	animated_sprite.sprite_frames = frames


func _toggle() -> void:
	_set_active(not is_active)
	timer.wait_time = cycle_on_time if is_active else cycle_off_time


func _set_active(active: bool) -> void:
	is_active = active
	hurtbox.monitoring = active
	hurtbox.monitorable = active
	animated_sprite.play("on" if active else "off")


func _on_hurtbox_body_entered(body: Node2D) -> void:
	if not is_active:
		return
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(damage, self)
