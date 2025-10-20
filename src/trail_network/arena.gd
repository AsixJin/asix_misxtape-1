class_name NetworkArena extends Node2D
 
@onready var panel_nodes = $BattleField/Panels

var panels := {}
var player_fighter : Fighter

func _ready() -> void:
	create_fighter()
	create_fighter()
	pass
	
func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("dpad_up"):
		player_fighter.move(Vector2i.UP)
	elif Input.is_action_just_pressed("dpad_down"):
		player_fighter.move(Vector2i.DOWN)
	elif Input.is_action_just_pressed("dpad_left"):
		player_fighter.move(Vector2i.LEFT)
	elif Input.is_action_just_pressed("dpad_right"):
		player_fighter.move(Vector2i.RIGHT)
	elif Input.is_action_just_pressed("action_1"):
		player_fighter.attack()

func create_fighter():
	var scene = load("res://src/trail_network/fighters/archer/archer_fighter.tscn")
	var fighter : Fighter = scene.instantiate()
	fighter.ref_arena = self
	add_child(fighter)
	if not player_fighter:
		player_fighter = fighter
		fighter.is_opposing_team = false
		fighter.flip_sprite()
		move_fighter(fighter, Vector2i(1, 1))
	else:
		move_fighter(fighter, Vector2i(4, 1))
		
func check_panel(id : String):
	return panels.get(id, false)
	
func move_fighter(fighter : Fighter, new_coords : Vector2i):
	# Check to see if coords are in bounds
	if (new_coords.x < 0 or new_coords.x > 5) or (new_coords.y < 0 or new_coords.y > 2):
		return false
	# Get the panel and check if it belongs to fighter
	var panel : ArenaPanel = panel_nodes.get_child(new_coords.x).get_child(new_coords.y)
	if fighter.is_opposing_team != panel.is_opposing_panel:
		return false
	# Check if the panel is free
	var new_panel_id = str(new_coords.x, new_coords.y)
	if check_panel(new_panel_id):
		return false
	else:
		# Remove fighter from previous panel
		panels.erase(fighter.panel_id)
		# Add fighter to new panel
		panels[new_panel_id] = fighter
		fighter.panel_coords = new_coords
		# Move the fighter
		fighter.position = panel.get_marker_position()
		return true
	
func _connect_signals(signal_connections: Dictionary) -> void:
	var signals_from_one_node: Dictionary
	var target_nodes: Array
	var source_signal: Signal
	var target_function: Callable

	for source_node: String in signal_connections.keys():
		signals_from_one_node = signal_connections[source_node]

		for signal_name: String in signals_from_one_node.keys():
			target_nodes = signals_from_one_node[signal_name]

			for target_node: String in target_nodes:
				source_signal = get_node(source_node)[signal_name]
				target_function = get_node(target_node)["_on_" +
						Array(source_node.split("/")).pop_back() + "_" +
						signal_name]

				if source_signal.connect(target_function) == \
						ERR_INVALID_PARAMETER:
					push_error("Signal error: %s -> %s, %s." %
							[source_node, target_node, signal_name])

func _connect_nodes(node_connections: Dictionary) -> void:
	var source_reference: String
	var target_nodes: Array

	for source_node: String in node_connections.keys():
		source_reference = "_ref_" + Array(source_node.split("/")).pop_back()
		target_nodes = node_connections[source_node]
		for target_node: String in target_nodes:
			get_node(target_node)[source_reference] = get_node(source_node)
