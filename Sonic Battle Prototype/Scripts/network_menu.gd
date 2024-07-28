extends Control


func _ready():
	# hide the server ip panel
	$server_ip.hide()
	# connect the "list_updated" signal from Network to the "update_list" method here
	Network.list_updated.connect(self.update_list)
	# connect the "connection_reseted" signal from Network to the "show_connection_error" method here
	Network.connection_reseted.connect(self.show_connection_error)


func _on_create_server_pressed():
	disable_connection_buttons()
	# the server will provide the ip when created
	# the name must be updated before creating
	Network.update_name($player_name.text)
	Network.create_new_server()
	# pass the server ip so that clients know where to connect
	var current_ip = Network.return_ip()
	$server_ip.show()
	$server_ip.text = "Pass the following IP to connect clients to your server: \n" + str(current_ip)


func _on_join_server_pressed():
	disable_connection_buttons()
	# the name and ip must be updated before creating
	Network.update_ip($IP.text)
	Network.update_name($player_name.text)
	Network.create_new_client()


func disable_connection_buttons():
	# disable create and join buttons
	$CreateServer.disabled = true
	$JoinServer.disabled = true


func update_list():
	# the list is required to update the list
	var list = Network.return_list()
	$players_list.clear()
	# add each players' name to the list
	for i in range(list.size()):
		# add a "you" in the list for the player to see where it is
		if list[i][0] == Network.id:
			$players_list.add_item(list[i][1] + str(" (you)"))
		else:
			$players_list.add_item(list[i][1])
	


func show_connection_error(error_message):
	# hide the message with the server ip
	$server_ip.hide()
	$server_ip.text = ""
	# show error screen
	$connection_error_screen.show()
	$connection_error_screen/error.text = error_message + " Connection Error"


func _on_error_button_pressed():
	# enable the create and join buttons
	$CreateServer.disabled = false
	$JoinServer.disabled = false
	$connection_error_screen.hide()


func _on_next_pressed():
	# only the server can proceed
	if multiplayer.is_server():
		rpc("next_menu")
	else:
		return


@rpc("any_peer", "call_local")
func next_menu():
	# go to next menu screen
	get_parent().after_online_setup()
	#get_tree().change_scene_to_file("res://world1.tscn")
	#print("next menu/start game button")
