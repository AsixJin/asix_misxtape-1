@abstract class_name BaseController extends Node

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

func _ready() -> void:
	if get_parent() is Fighter:
		fighter = get_parent()
	else:
		print("Parent is not a Fighhter...")
		queue_free()
		return

@abstract func transition_state(new_state:State) -> void
