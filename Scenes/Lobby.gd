extends Node

var room_code
var max_connect_time = 100 #if this time is exceeded when joining a game, a fail message is displayed
var room_code_length = 4
var is_host = false
var nickname
var own_port
var host_address
var host_port
var players_joined = 0
var num_players = 100

func _ready():
	multiplayer.peer_connected.connect(Callable(self, "_player_connected"))

#Handle player input

func _on_ButtonHost_pressed():
	is_host=true
	room_code=""
	for i in range(room_code_length):
		room_code+=char(randi_range(65,90))
	connection_setup()
	$HolePunch.start_traversal(room_code, true, Globals.client_name, nickname) #Attempt to connect to server as host
	$Status.text = ("Status: Connecting to server...")

func _on_ButtonJoin_pressed():
	if $MainUI/RoomCode.text.length() == room_code_length:
		is_host = false
		room_code = $MainUI/RoomCode.text.to_upper()
		connection_setup()
		$HolePunch.start_traversal(room_code, false, Globals.client_name, nickname) #Attempt to connect to server as client
		$Status.text = ("Status: Connecting to session...")
	else:
		$Status.text = "Status: Invalid roomcode!"

func _on_ButtonCancel_pressed():
	if(is_host):
		$HolePunch.close_session()
	else:
		$HolePunch.client_disconnect()

func _on_ButtonStart_pressed():
	$HolePunch.finalize_peers()

#Handle holepunch messages

func _on_HolePunch_hole_punched(my_port, hosts_port, hosts_address,num_plyrs):
	print("ready to join: "+str(hosts_address)+":"+str(hosts_port)+" / "+str(my_port))
	own_port = my_port
	host_address = hosts_address
	host_port = hosts_port
	num_players = num_plyrs
	$FailTimer.stop()
	$Status.text = "Status: Connection successful, starting game!"
	players_joined = 0
	if $HolePunch.is_host:
		$ConnectTimer.start(1) #Waiting for port to become unused to start game
	else:
		$ConnectTimer.start(3) #Waiting for host to start game

func _on_HolePunch_update_lobby(nicknames,max_players):
	var lobby_message = "Lobby "+str(nicknames.size())+"/"+str(max_players)+"\n"
	for n in nicknames:
		lobby_message+=n+"\n"
	if nicknames.size()>1: #you're not alone!
		$Status.text = "Status: Ready to play!"
	else:
		$Status.text = "Status: Room open!"
	$ConnectingUI/Playerlist.text = lobby_message

func _on_HolePunch_session_registered():
	$Status.text = ("Status: Room open!")
	$FailTimer.stop() #server responded!

func _on_HolePunch_return_unsuccessful(message):
	$Status.text=message
	reinit()

#Finalize connection

func _player_connected(_id): #When player connects, load game scene
	players_joined += 1
	print(str(players_joined)+" out of "+str(num_players)+" joined.")
	if players_joined >= num_players:
		var game = preload("res://Scenes/GameScene.tscn").instantiate()
		get_tree().get_root().add_child(game)
		queue_free()

func _on_ConnectTimer_timeout():
	print("connection timer timeout")
	if $HolePunch.is_host:
		print("hosting on port ",own_port)
		var net = ENetMultiplayerPeer.new() #Create regular godot peer to peer server
		net.create_server(own_port, 32) #You can follow regular godot networking tutorials to extend this
		multiplayer.set_multiplayer_peer(net)
	else:
		print("joining on address ",host_address,":",host_port," using ", own_port)
		var net = ENetMultiplayerPeer.new() #Connect to host
		net.create_client(host_address, host_port, 0, 0, own_port)
		multiplayer.set_multiplayer_peer(net)
	$FailTimer.start(max_connect_time)

func _on_FailTimer_timeout():
	$Status.text = "Status: Connection timed out!"
	reinit()

#Utility/UI

func reinit():
	$FailTimer.stop()
	$ConnectingUI.visible=false
	$MainUI.visible=true
	$MainUI/Nickname.text = ""

func connection_setup():
	$ConnectingUI.visible = true
	$MainUI.visible = false
	$ConnectingUI/ButtonStart.visible = is_host
	$ConnectingUI/Playerlist.text = "Lobby 1/1"
	$ConnectingUI/CodeDisplay.text = "Room Code: "+room_code
	$FailTimer.start(max_connect_time)
	nickname = $MainUI/Nickname.text
	if nickname == "":
		nickname = "Player"
