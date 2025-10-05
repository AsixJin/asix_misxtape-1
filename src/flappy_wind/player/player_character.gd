class_name PlatformerCharacter extends CharacterBody2D

enum State {
	GROUND,
	JUMP,
	AIR_DASH,
	DOUBLE_JUMP,
	FALL
}

const MAX_JUMPS := 2

@export_category("Speed")
@export var acceleration := 700.0 # Default: 700.0
@export var decleration := 1400.0 # Default: 1400.0
@export var max_speed := 120.0 # Default: 120.0
@export var air_acceleration := 500.0 # Default: 500.0
@export var max_fall_speed := 250.0 # Default: 250.0

@export_category("Jump")
@export_range(10.0, 200.0) var jump_height := 50.0
@export_range(0.1, 1.5) var jump_time_to_peak := 0.4
@export_range(0.1, 1.5) var jump_time_to_descent := 0.2
@export_range(50.0, 200.0) var jump_horizontal_distance := 80.0
@export_range(5.0, 50.0) var jump_cut_divider := 15.0
@export_range(0.0, 2.0) var coyote_time := 0.1

@export_category("Double Jump")
@export_range(10.0, 200.0) var double_jump_height := 50.0
@export_range(0.1, 1.5) var double_jump_time_to_peak := 0.5
@export_range(0.1, 1.5) var double_jump_time_to_descent := 0.2

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var dust: GPUParticles2D = %Dust
@onready var jump_speed := calculate_jump_speed(jump_height, jump_time_to_peak)
@onready var jump_gravity := calculate_jump_gravity(jump_height, jump_time_to_peak)
@onready var fall_gravity := calculate_fall_gravity(jump_height, jump_time_to_descent)
@onready var jump_horizontal_speed := calculate_jump_horizontal_speed(jump_horizontal_distance, jump_time_to_peak, jump_time_to_descent)
@onready var double_jump_speed := calculate_jump_speed(double_jump_height, double_jump_time_to_peak)
@onready var double_jump_gravity := calculate_jump_gravity(double_jump_height, double_jump_time_to_peak)
@onready var double_jump_fall_gravity := calculate_fall_gravity(double_jump_height, double_jump_time_to_descent)
@onready var coyote_timer := Timer.new()

var current_state: State = State.GROUND
var direction_x := 0.0
var current_gravity := 0.0
var jump_count := 0

func _ready() -> void:
	_transition_to_state(current_state)
	coyote_timer.wait_time = coyote_time
	coyote_timer.one_shot = true
	add_child(coyote_timer)
	
func _physics_process(delta: float) -> void:
	direction_x = signf(Input.get_axis("dpad_left", "dpad_right"))
	
	match current_state:
		State.GROUND:
			process_ground_state(delta)
		State.JUMP:
			process_jump_state(delta)
		State.FALL:
			process_fall_state(delta)
		State.DOUBLE_JUMP:
			process_double_jump_state(delta)
			
	velocity.y += current_gravity * delta
	velocity.y = minf(velocity.y, max_fall_speed)
	move_and_slide()

func process_ground_state(delta: float) -> void:
	var is_moving := absf(direction_x) > 0.0
	dust.emitting = absf(direction_x) > 0.0
	if is_moving:
		velocity.x += direction_x * acceleration * delta
		velocity.x = clampf(velocity.x, -max_speed, max_speed)
		flip_sprite()
		sprite.play("run")
	else:
		velocity.x = move_toward(velocity.x, 0, decleration * delta)
		sprite.play("idle")
		
	if Input.is_action_just_pressed("action_1"):
		_transition_to_state(State.JUMP)
	elif not is_on_floor():
		_transition_to_state(State.FALL)
		
func process_jump_state(delta: float) -> void:
	if direction_x != 0:
		velocity.x += air_acceleration * direction_x * delta
		velocity.x = clampf(velocity.x, -jump_horizontal_speed, jump_horizontal_speed)
		flip_sprite()
		
	if Input.is_action_just_released("action_1"):
		var jump_cut_speed := jump_speed / jump_cut_divider
		if velocity.y < 0.0 and velocity.y < jump_cut_speed:
			velocity.y = jump_cut_speed
			
	if velocity.y >= 0.0:
		_transition_to_state(State.FALL)
	elif Input.is_action_just_pressed("action_1") and jump_count < MAX_JUMPS:
		_transition_to_state(State.DOUBLE_JUMP)
		
func process_fall_state(delta: float) -> void:
	if direction_x != 0.0:
		velocity.x += air_acceleration * direction_x * delta
		velocity.x = clampf(velocity.x, -jump_horizontal_speed, jump_horizontal_speed)
		flip_sprite()
	
	if Input.is_action_just_pressed("action_1"):
		if not coyote_timer.is_stopped():
			_transition_to_state(State.JUMP)
		elif jump_count < MAX_JUMPS:
			_transition_to_state(State.DOUBLE_JUMP)
			
	if is_on_floor():
		_transition_to_state(State.GROUND)

func process_double_jump_state(delta: float) -> void:
	if direction_x != 0.0:
		velocity.x += air_acceleration * direction_x * delta
		velocity.x = clampf(velocity.x, -jump_horizontal_speed, jump_horizontal_speed)
		flip_sprite()
		
	if velocity.y >= 0.0:
		_transition_to_state(State.FALL)

func _transition_to_state(new_state: State) -> void:
	var previous_state := current_state
	current_state = new_state
	
	match previous_state:
		State.FALL:
			coyote_timer.stop()
		
	match current_state:
		State.GROUND:
			jump_count = 0
			if previous_state == State.FALL:
				play_tween_touch_ground()
		State.JUMP:
			velocity.y = jump_speed
			current_gravity = jump_gravity
			velocity.x = direction_x * jump_horizontal_speed
			sprite.play("jump")
			jump_count = 1
			play_tween_jump()
			dust.emitting = true
		State.DOUBLE_JUMP:
			velocity.y = double_jump_speed
			current_gravity = double_jump_gravity
			velocity.x = direction_x * jump_horizontal_speed
			sprite.play("double_jump")
			jump_count = MAX_JUMPS
			play_tween_jump()
			dust.emitting = true
		State.FALL:
			sprite.play("fall")
			if jump_count == MAX_JUMPS:
				current_gravity = double_jump_fall_gravity
			else:
				current_gravity = fall_gravity
				
			if previous_state == State.GROUND:
				coyote_timer.start()

func play_tween_jump() -> void:
	var tween := create_tween()
	tween.tween_property(sprite, "scale", Vector2(sprite.scale.x * 1.15, 0.86), 0.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(sprite, "scale", Vector2(sprite.scale.x * 0.86, 1.15), 0.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(sprite, "scale", sprite.scale * Vector2.ONE, 0.15)

func play_tween_touch_ground() -> void:
	var tween := create_tween()
	tween.tween_property(sprite, "scale", Vector2(sprite.scale.x * 1.1, 0.9), 0.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(sprite, "scale", Vector2(sprite.scale.x * 0.9, 1.1), 0.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(sprite, "scale", sprite.scale * Vector2.ONE, 0.15)

func flip_sprite():
	var sprite_x_scale = 1.0 
	if direction_x < 0.0:
		sprite_x_scale = -1.0
	sprite.scale = Vector2(sprite_x_scale, 1.0)
	
func calculate_jump_speed(height: float, time_to_peak: float) -> float:
	return (-2.0 * height) / time_to_peak
	
func calculate_jump_gravity(height: float, time_to_peak: float) -> float:
	return (2.0 * height) / pow(time_to_peak, 2.0)
	
func calculate_fall_gravity(height: float, time_to_descent: float) -> float:
	return (2.0 * height) / pow(time_to_descent, 2.0)
	
func calculate_jump_horizontal_speed(distance: float, time_to_peak: float, time_to_descent: float) -> float:
	return distance / (time_to_peak + time_to_descent)
