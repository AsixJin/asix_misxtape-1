class_name FighterController extends Node

const MIN_CHARGE_TIME = 2.0

enum State {
	IDLE,
	ATTACK,
	MAGIC_ATTACK,
	CHARGE,
	HURT,
	DEATH
}

var fighter : Fighter
var current_state := State.IDLE
var charge_time := 0.0

func _ready() -> void:
	if get_parent() is Fighter:
		fighter = get_parent()
	else:
		print("Parent is not a Fighhter...")
		queue_free()
		return
		
func _process(delta: float) -> void:
	match current_state:
		State.IDLE:
			_process_idle_state(delta)
		State.CHARGE:
			_process_charge_state(delta)
			
func _process_idle_state(_delta: float) -> void:
	if Input.is_action_just_pressed("dpad_up"):
		fighter.move(Vector2i.UP)
	elif Input.is_action_just_pressed("dpad_down"):
		fighter.move(Vector2i.DOWN)
	elif Input.is_action_just_pressed("dpad_left"):
		fighter.move(Vector2i.LEFT)
	elif Input.is_action_just_pressed("dpad_right"):
		fighter.move(Vector2i.RIGHT)
		
	if Input.is_action_just_pressed("action_1"):
		transition_state(State.ATTACK)
		fighter.attack()
	if Input.is_action_just_pressed("action_2"):
		transition_state(State.CHARGE)
		
func _process_charge_state(delta):
	if Input.is_action_pressed("action_2"):
		charge_time += delta
	elif Input.is_action_just_released("action_2"):
		if charge_time >= MIN_CHARGE_TIME:
			print("You've charged enough my G...")
			await fighter.throw_magic()
		print(str("Charge Time: ", charge_time))
		transition_state(State.IDLE)
	
func transition_state(new_state:State) -> void:
	var prev_state = current_state
	
	match prev_state:
		State.CHARGE:
			charge_time = 0
		_:
			pass
			
	current_state = new_state
	match current_state:
		State.IDLE:
			fighter.play_animation("idle")
		State.ATTACK:
			await fighter.attack()
			transition_state(State.IDLE)
		State.CHARGE:
			fighter.start_charge()
