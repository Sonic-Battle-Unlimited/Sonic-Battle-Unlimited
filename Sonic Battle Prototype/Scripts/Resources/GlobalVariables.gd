extends Node

signal camera_orientation_changed

# right now everyone and everything should have a gravity of 20.
var gravity: float = 20.0

# to store the main menu node
var main_menu

# store rather if the player selected to play online or offline
var play_online: bool = false

# server/client related  variables
var server_node
var character_id

enum modes {battle, story, challenge}
# which mode was selected (battle mode, story mode,...)
var play_mode = modes.battle

# bellow there are many "current" and "selected" variables
# the "current" is used to track and later delete the instantiated scene
# the "selected" is used to instantiate a new one
# enumerator with all playable characters
# maybe make another list for unlockable characters
enum playable_characters {sonic, shadow}
var character_selected = playable_characters.sonic
# to store the character node that was instantiated in-game
var current_character

# enumerator for all world areas
# which contain some number of hubs each
# maybe make another list for unlockable characters
#enum playable_areas {world1}
# store the area selected in the main menu
var area_selected: PackedScene # = playable_areas.area1
# store the instantiated area
var current_area

#enum playable_hubs {hub1}
# store the hub selected in the main menu
var hub_selected: PackedScene
# current hub instantiated in-game
var current_hub

# stage selected (with PackedScene type) by hitting a hub marker in a hub area
var stage_selected: PackedScene
# current stage instantiated in-game
var current_stage

#var enemy_bots: Array[CharacterBody3D]

# timer to count the time scattered rings last
#var scattered_ring_timer: SceneTreeTimer
# time to set the scattered rings timer
const SCATTERED_RINGS_TIME = 4.0

var ring_count_towards_extra_life: int = 0

var current_ability_seletor
# timer to select ability and place character on stage
var select_ability_timer: SceneTreeTimer

var selected_abilities: Array
var character_points: int = 0
var defeated: bool = true

var bot_points: int = 0

# variables for the hud on areas and hubs
var total_rings: int = 0
var extra_lives: int = 2

# set difficulty level
# 					 [easy, normal, hard] respectively
var difficulty_levels = [0.2, 0.1, 0.0]
var current_difficulty = difficulty_levels[2] #difficulty.hard

# win condition
var points_to_win: int = 2
# store if someone won the game already
var game_ended: bool = false


func reset_win_conditions():
	game_ended = false
	character_points = 0
	bot_points = 0


## the character that triggers this method is the winner of the battle
func win(winner):
	game_ended = true
	var score_menu = Instantiables.create(Instantiables.objects.SCORESCREEN)
	score_menu.winner = winner.name
	main_menu.get_parent().add_child(score_menu, true)
	
	# add rings stored to total amount
	if current_character.rings > 0:
		GlobalVariables.total_rings += current_character.rings
