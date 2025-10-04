class_name GhostCharacter extends CharacterBody2D

enum State {
	FALL,
	FLY
}

@export_category("Horizontal Speed")
@export var acceleration := 20
@export var decleration := 10
@export var max_speed := 30

@export_category("Vertical Speed")
@export var ascent_speed := 50
@export var descent_speed := 25
@export var max_flight_speed := 50


func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("action_1"):
		velocity.y -= ascent_speed * delta
	else:
		velocity.y += descent_speed * delta
	velocity.y = clampf(velocity.y, -max_flight_speed, max_flight_speed)
	
	if not is_on_floor():
		if Input.is_action_pressed("dpad_right"):
			velocity.x += acceleration * delta
		elif Input.is_action_pressed("dpad_left"):
			velocity.x -= acceleration * delta
		else:
			velocity.x = move_toward(velocity.x, 0, decleration * delta)
	else:
		velocity.x = 0
	velocity.x = clampf(velocity.x, -max_speed, max_speed)
		
	move_and_slide()
