class_name Fighter extends Area2D

const ARROW_SCENE_PATH = "res://src/trail_network/projectiles/arrow/arrow_projectile.tscn"
const ARROW_POSITION_OFFSET = Vector2(14, -1)

const SHARD_SCENE_PATH = "res://src/trail_network/projectiles/ice_shard/ice_shard.tscn"
const SHARD_POSITION_OFFSET = Vector2(24, -1)

@onready var controller : BaseController
@onready var sprite := $Sprite
@onready var anim := $Anim
@onready var magic_sprite = $Sprite/Magic

@export var magic : MagicType

var ref_arena : NetworkArena
var panel_coords := Vector2i.ZERO
var panel_id : String :
	get:
		return str(panel_coords.x, panel_coords.y)

# The opposing team are on the right side
var is_opposing_team := true

var health := 3
var selected_magic = 0

func play_animation(anim_name, await_animation = false):
	anim.play(anim_name)
	if await_animation:
		await anim.animation_finished
	
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
	await play_animation("attack", true)
	
func throw_magic():
	if magic:
		magic_sprite.texture = magic.throw_texture
		await play_animation("throw_magic", true)
	
func switch_magic():
	selected_magic = 0 if selected_magic >= 3 else selected_magic + 1
	var new_magic = load("res://src/trail_network/magic_types/ice_magic.tres")
	match selected_magic:
		1:
			new_magic = load("res://src/trail_network/magic_types/earth_magic.tres")
		2:
			new_magic = load("res://src/trail_network/magic_types/fire_magic.tres")
		3:
			new_magic = load("res://src/trail_network/magic_types/wind_magic.tres")
	magic = new_magic
	
func start_charge():
	if magic:
		$Sprite/ChrageBase.texture = magic.charge_base_texture
		$Sprite/ChargeEffect.texture = magic.charge_effect_texture
	play_animation("charge")
	
func take_damage():
	await play_animation("hurt", true)
	health -= 1
	if health <= 0:
		death()
	else:
		play_animation("idle")
	
func death():
	if controller:
		controller.queue_free()
	await play_animation("death", true)
	queue_free()
	
func dance():
	play_animation("metal_dance")
	
func flip_sprite():
	sprite.scale = Vector2(1 if sprite.scale.x <= -1 else -1 , 1)
	#sprite.flip_h = !sprite.flip_h
	#sprite.offset = Vector2(0 if sprite.flip_h else -1, 0.5)
	pass

func hide_charge_sprites():
	$Sprite/ChargeEffect.hide()
	$Sprite/ChrageBase.hide()

# NOTE: This works as intended but
# I think I can implement this a little
# better but we'll save it for later.
func spawn_arrow():
	var scene = load(ARROW_SCENE_PATH)
	var arrow : Projectile = scene.instantiate()
	get_parent().add_child(arrow)
	if is_opposing_team:
		arrow.global_position = global_position - ARROW_POSITION_OFFSET
	else:
		arrow.global_position = global_position + (ARROW_POSITION_OFFSET * Vector2(1, -1))
		arrow.rotate(deg_to_rad(180))
		
func spawn_magic():
	if magic:
		var scene = magic.projectile_scene
		var shard : Projectile = scene.instantiate()
		get_parent().add_child(shard)
		if is_opposing_team:
			shard.global_position = global_position - SHARD_POSITION_OFFSET
		else:
			shard.global_position = global_position + (SHARD_POSITION_OFFSET * Vector2(1, -1))
			shard.rotate(deg_to_rad(180))
