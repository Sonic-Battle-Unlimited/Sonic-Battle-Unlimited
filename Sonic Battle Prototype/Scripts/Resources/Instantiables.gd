extends Node

# this script was autoloaded so you can put all preloaded scenes in one place
# so you can change which scene is instantiated in multiple places from here
# all script that requires a scene to be instantiate should
# use this Instantiables script.

# The prefab for spawning Sonic's "shot" projectile.
const SHOT_PROJECTILE = preload("res://Scenes/SonicWave.tscn")

# The ring prefab that Sonic will throw when he uses his "pow" move on the ground.
const RING = preload("res://Scenes/ThrowRing.tscn")

# The mine prefab for Sonic's "set" special moves.
const SET_MINE = preload("res://Scenes/SonicMine.tscn")

# ability selection menu
const ABILITY_SELECT = preload("res://Scenes/ability_select.tscn")

# final score screen
const SCORE_SCREEN = preload("res://Scenes/score_screen.tscn")

# pointer to spawn the character at target spot
const POINTER_SPAWNER = preload("res://Scenes/pointer_spawner.tscn")

# sonic character
const SONIC = preload("res://Scenes/Sonic.tscn")

const WORLD_AREA = preload("res://Scenes/Areas/world_1.tscn")

# shadow character
const SHADOW = preload("res://Scenes/Shadow.tscn")

# the hub area with the hub markers that lead to stages
const HUB_TEST = preload("res://Scenes/Hubs/city_hub.tscn")

# to match-case block
# should get a variable with the name of a string instead
# attacks (shots and sets)
enum objects {SHOT_PROJECTILE, RING, SET_MINE, ABILITYSELECT, POINTERSPAWNER, SCORESCREEN}

# pointer spawner is not a screen though
enum screens {ABILITYSELECT, POINTERSPAWNER, SCORESCREEN}

# hubs
enum hubs {HUBTEST}


## create a Sonic character
# called from pointer_spawner
func add_player(parent_node, spawn_position = Vector3.ZERO):
	GlobalVariables.defeated = false
	
	var player
	if GlobalVariables.character_selected == GlobalVariables.playable_characters.sonic:
		player = SONIC.instantiate()
	elif GlobalVariables.character_selected == GlobalVariables.playable_characters.shadow:
		player = SHADOW.instantiate()
	player.name = str(GlobalVariables.character_id)
	# add the selected abilities to the character
	player.set_abilities(GlobalVariables.selected_abilities)
	player.position = spawn_position + Vector3(0, 0.2, 0)
	parent_node.add_child(player, true)


## create a preloaded scene
func create(object_to_create, place_to_add_as_child = null):
	var new_object
	
	# there should be a way to get a variable with the name equal to a string
	# using match-case for now
	match object_to_create:
		objects.SHOT_PROJECTILE:
			new_object = SHOT_PROJECTILE.instantiate()
		objects.RING:
			new_object = RING.instantiate()
		objects.SET_MINE:
			new_object = SET_MINE.instantiate()
		
		objects.ABILITYSELECT:
			new_object = ABILITY_SELECT.instantiate()
		objects.POINTERSPAWNER:
			new_object = POINTER_SPAWNER.instantiate()
		objects.SCORESCREEN:
			new_object = SCORE_SCREEN.instantiate()
			
	if place_to_add_as_child == null:
		return new_object


## got to area
# areas that contains hubs
func go_to_area(selected_area):
	delete_places()
	
	load_area(selected_area)
	
	# allow a new character to be spawned
	if GlobalVariables.current_character != null:
		GlobalVariables.current_character.queue_free()
		# the reference is still there so nullify it
		GlobalVariables.current_character = null
	# create the character in the Main scene
	add_player(GlobalVariables.main_menu.get_parent())


func load_area(new_area):
	# store the current area on global variables
	GlobalVariables.current_area = new_area.instantiate()
	# create the area in the Main scene
	GlobalVariables.main_menu.get_parent().add_child(GlobalVariables.current_area) # GlobalVariables.area_selected) 


## go to a hub
# hubs that contains stages
# called from menu after an area is selected
# it should go to an area first them the player selects a hub
func go_to_hub(selected_hub):
	delete_places()
	
	load_hub(selected_hub)
	
	# allow a new character to be spawned
	#GlobalVariables.main_menu.canvas_server_menu.remove_player(multiplayer.multiplayer_peer)
	if GlobalVariables.current_character != null:
		GlobalVariables.current_character.queue_free()
		# the reference is still there so nullify it
		GlobalVariables.current_character = null
	# create the character in the Main scene
	add_player(GlobalVariables.main_menu.get_parent())


## load a hub in the Main hierarchy
func load_hub(hub_to_create):
	# store the current hub on global variables
	GlobalVariables.current_hub = hub_to_create.instantiate() #new_hub
	# create the hub in the Main scene
	GlobalVariables.main_menu.get_parent().add_child(GlobalVariables.current_hub)


## bridge from the hub area's hub marker to the selected stage
func go_to_stage(new_stage: PackedScene):
	# unpause if restarted
	get_tree().paused = false
	
	# reset win condition variables
	GlobalVariables.game_ended = false
	GlobalVariables.character_points = 0
	
	delete_places()
	
	# allow a new character to be spawned
	ServerJoin.remove_player(multiplayer.multiplayer_peer)
	# spawn a character with ability selector
	respawn()
	
	# create the new stage
	load_stage(new_stage)


## load a stage in the Main hierarchy
func load_stage(new_stage):
	# store the current stage on global variables
	GlobalVariables.current_stage = new_stage.instantiate()
	# create the stage in the Main scene
	GlobalVariables.main_menu.get_parent().add_child(GlobalVariables.current_stage)


## respawn the character
## ability selection will be spawn first, then pointer selector, then the character
func respawn():
	if GlobalVariables.current_character != null:
		GlobalVariables.current_character.queue_free()
		GlobalVariables.current_character = null
	# create the ability selection that will later create the
	# point spawner to spawn the character on the stage
	var ability_selection_menu = create(objects.ABILITYSELECT)
	GlobalVariables.main_menu.get_parent().add_child(ability_selection_menu, true)


func delete_places():
	# delete area
	if GlobalVariables.current_area != null:
		GlobalVariables.current_area.queue_free()
		GlobalVariables.current_area = null
	# delete hub if it's restarting the scene
	if GlobalVariables.current_hub != null:
		GlobalVariables.current_hub.queue_free()
		GlobalVariables.current_hub = null
	# delete stage if it's restarting the scene from score screen
	if GlobalVariables.current_stage != null:
		GlobalVariables.current_stage.queue_free()
		GlobalVariables.current_stage = null


## go to previous ambient
## exit from stage to hub
## exit from hub to area
## exit from area to main menu
func exit_current_ambient():
	if GlobalVariables.hub_selected != null and GlobalVariables.current_hub == null:
		# if on stage, return to current hub
		go_to_hub(GlobalVariables.hub_selected)
	elif GlobalVariables.area_selected != null:
		# if on hub, return to current area
		go_to_area(GlobalVariables.area_selected)
	else:
		# if on area, return to main menu
		get_tree().reload_current_scene()
