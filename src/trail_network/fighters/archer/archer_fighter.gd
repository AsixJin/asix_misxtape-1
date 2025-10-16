class_name Fighter extends Area2D

const ARROW_SCENE_PATH = "res://src/trail_network/projectiles/arrow/arrow_projectile.tscn"
const ARROW_POSITION_OFFSET = Vector2(-20, 4)

@onready var sprite := $Sprite

var ref_arena : NetworkArena
var panel_coords := Vector2i.ZERO
var panel_id : String :
	get:
		return str(panel_coords.x, panel_coords.y)

# The opposing team are on the right side
var is_opposing_team := true

var health := 3

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
	
func attack():
	sprite.play("attack")
	await sprite.animation_finished
	spawn_arrow()
	sprite.play("idle")
	
func take_damage():
	health -= 1
	if health <= 0:
		death()
	else:
		sprite.play("hurt")
		await sprite.animation_finished
		sprite.play("idle")
	
func death():
	sprite.play("death")
	await sprite.animation_finished
	queue_free()
	
func flip_sprite():
	sprite.flip_h = !sprite.flip_h

# NOTE: I need to find a way to position arrow
# but not having it move with it's parent (ie this node)
func spawn_arrow():
	var scene = load(ARROW_SCENE_PATH)
	var arrow : Projectile = scene.instantiate()
	add_child(arrow)
	arrow.position = ARROW_POSITION_OFFSET
	if not is_opposing_team:
		arrow.position *= (Vector2.LEFT + Vector2.DOWN)
		arrow.flip_sprite()
