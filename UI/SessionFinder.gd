extends Node

var socket = WebSocketPeer.new()
var online : bool

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	socket.poll()
	var status = socket.get_ready_state()
	
	online = status == WebSocketPeer.STATE_OPEN
	
	match( status ):
		WebSocketPeer.STATE_CLOSED :
			var error = socket.connect_to_url("wss://baldheadgames.hu:51224")
		WebSocketPeer.STATE_CONNECTING :
			pass
		WebSocketPeer.STATE_OPEN :
			messaging()



func messaging():
	var bytes = socket.get_available_packet_count( )
	if bytes == 0 : return
	var message = socket.get_packet().get_string_from_utf8 ( )
	var parts = message.split( "\r" )
	for part in parts:
		read_message( part )


func read_message( message ):
	if message == "" : return
	var message_object = JSON.parse_string( message )
	
	if message_object == null : return
	
	match( message_object["messageType"] ):
		"StartGame":
			switch_to_match( message_object )
		"JoinPrivateGame":
			if( !message_object["data"].has("port") ) : return
			switch_to_match( message_object )


func join_public_game(  ):
	var message = '{ "messageType" : "JoinPublicGame", "data" : { } }\r'
	socket.send_text(message)


func start_private_game( player_color : String ):
	var message = '{ "messageType" : "StartPrivateGame", "data" : { "playerColor" : "%s" } }\r' % player_color
	socket.send_text(message)


func join_private_game( game_id : String ):
	var message = '{ "messageType" : "JoinPrivateGame", "data" : { "gameId" : "%s" } }\r' % game_id
	socket.send_text(message)


func switch_to_match( message_object ):
	socket.close(3100, "Game started")
	GameVariables.port = message_object["data"]["port"]
	get_tree().change_scene_to_file("res://Match/match.tscn")
