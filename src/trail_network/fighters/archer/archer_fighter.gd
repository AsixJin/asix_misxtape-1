class_name Fighter extends Node2D

@onready var sprite := $Sprite

var ref_arena : NetworkArena
var panel_coords := Vector2i.ZERO
var panel_id : String :
	get:
		return str(panel_coords.x, panel_coords.y)

# The challengers are on the left side
var is_challenger := false

func move(direction) -> void:
	var new_coords = panel_coords
	match direction:
		Vector2i.UP:
			new_coords.y -= 1
		Vector2i.DOWN:
			new_coords.y += 1
		Vector2i.LEFT:
			new_coords.x -= 1
		Vector2i.RIGHT:
			new_coords.x += 1
	# Use the arena to move if possible and return whether we succeed
	var _move_successful = ref_arena.move_fighter(self, new_coords)
	
func flip_sprite():
	sprite.flip_h = !sprite.flip_h
