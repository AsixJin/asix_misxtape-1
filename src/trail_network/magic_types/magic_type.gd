class_name MagicType extends Resource

enum Type {
	ICE,
	FIRE
}

@export var type : Type
@export var charge_base_texture : Texture
@export var charge_effect_texture : Texture
@export var throw_texture : Texture

@export var projectile_scene : PackedScene
