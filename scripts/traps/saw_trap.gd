extends Node2D

@export var move_distance := 100.0
@export var move_speed := 80.0
@export var vertical := false
@export var damage := 1

@onready var saw_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hurtbox: Area2D = $Hurtbox

var origin: Vector2
var direction := 1.0


func _ready() -> void:
	origin = position
	var texture_on: Texture2D = load("res://Free/Traps/Saw/On (38x38).png")
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	frames.add_animation(&"spin")
	frames.set_animation_speed(&"spin", 14.0)
	frames.set_animation_loop(&"spin", true)
	var frame_size := Vector2i(38, 38)
	var columns := maxi(1, texture_on.get_width() / frame_size.x)
	for i in columns:
		var atlas := AtlasTexture.new()
		atlas.atlas = texture_on
		atlas.region = Rect2(i * frame_size.x, 0, frame_size.x, frame_size.y)
		frames.add_frame(&"spin", atlas)
	saw_sprite.sprite_frames = frames
	saw_sprite.play("spin")
	hurtbox.body_entered.connect(_on_hurtbox_body_entered)


func _process(delta: float) -> void:
	var axis := Vector2.DOWN if vertical else Vector2.RIGHT
	position += axis * direction * move_speed * delta
	var traveled := (position - origin).dot(axis)
	if absf(traveled) >= move_distance:
		direction *= -1.0


func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(damage, self)
