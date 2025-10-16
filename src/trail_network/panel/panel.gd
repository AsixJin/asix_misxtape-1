class_name ArenaPanel extends Node2D

@onready var panel_sprites := $PanelSprites
@onready var marker := $Marker

@export var is_opposing_panel := true

func _ready() -> void:
	if panel_sprites and is_opposing_panel:
		panel_sprites.modulate = Color.from_string("#ec5a00", Color.WHITE)
		
func get_marker_position():
	return marker.global_position
