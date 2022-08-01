# Godot Holepuncher Example Project

This project shows a simple implementation of the Godot Holepuncher plugin at https://github.com/SLGamesCregg/HolePuncher.
Please note that this requires a server with the python code at the linked repository.

## Setup

Open the project and go to Scenes/Lobby.tscn, click on 'HolePuncher', and in the inspector set Rendevouz Address and Port to what your server is running. You can configure the other options there too. Make sure to check Local Testing if you are planning on testing with multiple windows on your own computer, otherwise make sure it is unchecked.
Now if you launch the project, host, and join from another client you should be able to see little godot icon players that you can move around.

## Structure

The project is pretty simple, it's basically just providing a UI for interacting with the holepunching server.
Globals.tcsn/gd stores a global Player ID, loaded through Project Settings > AutoLoad.
Lobby.tcsn/gd interacts with the HolePunch server through the HolePunch node, controls all the UI, and instantiates the game scene when all peers have successfully connected.
GameScene.tcsn/gd is the actual game (though it's only bare minimum player movement). It spawns all the players, and it's completely seperate from the rest of the code. This means that it would work exactly the same if you connected to others through port forwarding and then started the game scene. This also means you can replace this section with your own game networking without needing to change much.
Player.tcsn/gd is a very simple networked node script. The GameScene calls set_network_master on it so clients know who's sending the data.