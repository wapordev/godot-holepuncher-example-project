extends Node

var client_name = ""

func _ready():
	randomize()
	client_name = "client" + str(randi())
