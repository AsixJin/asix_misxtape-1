class_name Projectile extends Area2D

@onready var sprite = $Sprite

@export var speed := 750

var max_range := 200.0

var _traveled_distance = 0.0

func _physics_process(delta: float) -> void:
	var distance := speed * delta
	var motion := Vector2.RIGHT.rotated(rotation) * distance

	position += motion

	_traveled_distance += distance
	if _traveled_distance > max_range:
		_destroy()

func flip_sprite():
	sprite.flip_h = !sprite.flip_h

func _destroy():
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area is Fighter:
		area.take_damage()
		_destroy()
