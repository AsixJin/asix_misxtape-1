class_name EnemyController extends BaseController

var action_time := 0.0

func _process(delta: float) -> void:
	match current_state:
		State.IDLE:
			_process_idle_state(delta)
			
func _process_idle_state(delta) -> void:
	action_time += delta
	if action_time >= 2:
		var player = fighter.ref_arena.player_fighter
		if player.panel_coords.y > fighter.panel_coords.y:
			fighter.move(Vector2i.DOWN)
		elif player.panel_coords.y < fighter.panel_coords.y:
			fighter.move(Vector2i.UP)
		else:
			transition_state(State.ATTACK)
		action_time = 0
		
func transition_state(new_state:State) -> void:
	var prev_state = current_state
	
	match prev_state:
		_:
			pass
			
	current_state = new_state
	match current_state:
		State.IDLE:
			fighter.play_animation("idle")
		State.ATTACK:
			await fighter.attack()
			transition_state(State.IDLE)
		State.DEATH:
			await fighter.death()
