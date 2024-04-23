extends Node
var socket = StreamPeerTCP.new()
var current_match = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	socket.poll()
	var status = socket.get_status()
	match( status ):
		StreamPeerTCP.STATUS_NONE :
			var error = socket.connect_to_host( "localhost", 51224 )
			%OnlineState.text = tr( "Offline" )
		StreamPeerTCP.STATUS_CONNECTED :
			%OnlineState.text = tr( "Online" )
			messaging()
	
	if current_match != null:
		current_match.find_child("NetworkClient")._process(delta)
	

func messaging():
	var bytes = socket.get_available_bytes( )
	if bytes == 0 : return
	var message = socket.get_utf8_string(bytes)
	var parts = message.split( "\r" )
	for part in parts:
		read_message( part )


func read_message( message ):
	if message == "" : return
	var message_object = JSON.parse_string( message )
	
	if message_object == null : return
	
	match( message_object["messageType"] ):
		"SessionStart":
			socket.disconnect_from_host()
			GameVariables.port = message_object["data"]["port"]
			get_tree().change_scene_to_file("res://Match/match.tscn")
		"StartPrivateGame":
			socket.disconnect_from_host()
			GameVariables.port = message_object["data"]["port"]
			GameVariables.role = "host"
			get_tree().change_scene_to_file("res://Match/match.tscn")
		"JoinPrivateGame":
			if( !message_object["data"].has("port") ) : return
			socket.disconnect_from_host()
			GameVariables.port = message_object["data"]["port"]
			GameVariables.role = "client"
			get_tree().change_scene_to_file("res://Match/match.tscn")


func start_private_game():
	var message = '{ "messageType" : "StartPrivateGame", "data" : { } }\r'
	socket.put_utf8_string(message)


func join_private_game( game_id : String ):
	var message = '{ "messageType" : "JoinPrivateGame", "data" : { "gameId" : "%s" } }\r' % game_id
	socket.put_utf8_string(message)

