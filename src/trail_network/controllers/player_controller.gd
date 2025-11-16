class_name FighterController extends BaseController

const MIN_CHARGE_TIME = 1

var charge_time := 0.0
		
func _process(delta: float) -> void:
	match current_state:
		State.IDLE:
			_process_idle_state(delta)
		State.CHARGE:
			_process_charge_state(delta)
		State.DANCE:
			_process_dance_state(delta)
			
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
	if Input.is_action_just_pressed("action_2"):
		transition_state(State.CHARGE)
	if Input.is_action_just_pressed("select_button"):
		transition_state(State.DANCE)
	if Input.is_action_just_pressed("start_button"):
		fighter.switch_magic()
	
func _process_dance_state(_delta: float) -> void:
	if Input.is_action_just_pressed("dpad_up"):
		transition_state(State.IDLE)
		fighter.move(Vector2i.UP)
	elif Input.is_action_just_pressed("dpad_down"):
		transition_state(State.IDLE)
		fighter.move(Vector2i.DOWN)
	elif Input.is_action_just_pressed("dpad_left"):
		transition_state(State.IDLE)
		fighter.move(Vector2i.LEFT)
	elif Input.is_action_just_pressed("dpad_right"):
		transition_state(State.IDLE)
		fighter.move(Vector2i.RIGHT)
	
func _process_charge_state(delta):
	if Input.is_action_pressed("action_2"):
		charge_time += delta
	elif Input.is_action_just_released("action_2"):
		fighter.hide_charge_sprites()
		if charge_time >= MIN_CHARGE_TIME:
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
		State.DANCE:
			fighter.dance()
