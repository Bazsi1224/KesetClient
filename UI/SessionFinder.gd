extends Node
var socket = StreamPeerTCP.new()
var online : bool

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	socket.poll()
	var status = socket.get_status()
	
	online = status == StreamPeerTCP.STATUS_CONNECTED
	
	match( status ):
		StreamPeerTCP.STATUS_NONE :
			var error = socket.connect_to_host( "46.29.138.226", 51224 )
		StreamPeerTCP.STATUS_CONNECTED :
			messaging()



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
		"StartGame":
			switch_to_match( message_object, "host" )
		"JoinPrivateGame":
			if( !message_object["data"].has("port") ) : return
			switch_to_match( message_object, "client" )


func join_public_game(  ):
	var message = '{ "messageType" : "JoinPublicGame", "data" : { } }\r'
	socket.put_utf8_string(message)


func start_private_game( player_color : String ):
	var message = '{ "messageType" : "StartPrivateGame", "data" : { "playerColor" : "%s" } }\r' % player_color
	socket.put_utf8_string(message)


func join_private_game( game_id : String ):
	var message = '{ "messageType" : "JoinPrivateGame", "data" : { "gameId" : "%s" } }\r' % game_id
	socket.put_utf8_string(message)


func switch_to_match( message_object, role ):
	socket.disconnect_from_host()
	GameVariables.port = message_object["data"]["port"]
	get_tree().change_scene_to_file("res://Match/match.tscn")
