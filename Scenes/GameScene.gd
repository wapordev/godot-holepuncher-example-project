extends Node2D

var host_player = null 
var host_id

func _ready():
	host_id = multiplayer.get_unique_id()
	host_player = create_player(host_id)
	var peers = multiplayer.get_peers()
	for peer in peers:
		create_player(peer)

func create_player(id):
	var player = preload("res://Objects/Player.tscn").instantiate()
	player.name = str(id)
	player.set_multiplayer_authority(id)
	#Player positions are randomized different for each player, but in this setup it doesn't matter
	#If you are going to actually use randomization in a multiplayer game, consider synchronizing rng seeds
	player.global_position = Vector2(randf_range(0,1024),randf_range(0,600))
	if id != host_id: #not us
		player.get_node("Sprite2D").modulate = Color.RED
	add_child(player)
	return player
