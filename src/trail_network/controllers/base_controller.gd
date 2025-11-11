@abstract class_name BaseController extends Node

enum State {
	IDLE,
	ATTACK,
	MAGIC_ATTACK,
	CHARGE,
	HURT,
	DEATH,
	DANCE
}

var fighter : Fighter
var current_state := State.IDLE

func _ready() -> void:
	if get_parent() is Fighter:
		fighter = get_parent()
		fighter.controller = self
	else:
		print("Parent is not a Fighhter...")
		queue_free()
		return

@abstract func transition_state(new_state:State) -> void

func transition_to_death():
	transition_state(State.DEATH)
