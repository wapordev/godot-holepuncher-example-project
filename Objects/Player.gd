extends KinematicBody2D
#NOTE: Once the players are connected, the connection is straight peer to peer, and you use regular godot networking
#Here I've made a player that just broadcasts its position to all other peers
#This is not a great player networking system, it's just to show that it's working

var speed = 200

remote func _set_position(pos):
	global_transform.origin = pos

func _physics_process(delta):
	if is_network_master():
		var axis = Vector2.ZERO
		axis.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
		axis.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
		move_and_slide(axis*speed)
		rpc_unreliable("_set_position", global_transform.origin) #Send signal to other clients
