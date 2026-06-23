extends Area2D

@export var fruit_type := "apple"
@export var points_override := -1

@onready var sprite: Sprite2D = $Sprite2D

const FRUIT_TEXTURES := {
	"apple": "res://ressource/Items/Fruits/Apple.png",
	"bananas": "res://ressource/Items/Fruits/Bananas.png",
	"cherries": "res://ressource/Items/Fruits/Cherries.png",
	"kiwi": "res://ressource/Items/Fruits/Kiwi.png",
	"melon": "res://ressource/Items/Fruits/Melon.png",
	"orange": "res://ressource/Items/Fruits/Orange.png",
	"pineapple": "res://ressource/Items/Fruits/Pineapple.png",
	"strawberry": "res://ressource/Items/Fruits/Strawberry.png",
}


func _ready() -> void:
	add_to_group("collectibles")
	if FRUIT_TEXTURES.has(fruit_type):
		sprite.texture = load(FRUIT_TEXTURES[fruit_type])
	body_entered.connect(_on_body_entered)
	var tween := create_tween().set_loops()
	tween.tween_property(sprite, "position:y", -4.0, 0.5).set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite, "position:y", 0.0, 0.5).set_trans(Tween.TRANS_SINE)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	
	var points: int
	if points_override > 0:
		points = points_override
	else:
		points = GameManager.FRUIT_SCORES.get(fruit_type, 10)
	
	GameManager.add_score(points)
	if body.has_method("apply_fruit_bonus"):
		body.apply_fruit_bonus(fruit_type)
	queue_free()
