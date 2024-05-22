extends Node
var socket = WebSocketPeer.new()
var user_key : String
var player_color : String
var connecting_time = 0
var online : bool
var raw_game_state : String
var phase : GamePhaseEnum = GamePhaseEnum.WAITING
var login_phase = LoginPhaseEnum.INIT

enum GamePhaseEnum { WAITING ,PLAYING, ENDING }
enum LoginPhaseEnum { INIT, LOGGING_IN, LOGGED_IN }

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	socket.poll()
	var status = socket.get_ready_state()
	
	online = status == WebSocketPeer.STATE_OPEN
	
	match( status ):
		WebSocketPeer.STATE_CLOSED :
			var error = socket.connect_to_url( "wss://baldheadgames.hu:" + str( GameVariables.port ) )
			$AliveTimer.start(1)
		WebSocketPeer.STATE_CONNECTING:
			connecting_time += delta
			if connecting_time > 5 : 
				close_connection()
		WebSocketPeer.STATE_OPEN :
			messaging()
			handle_login()
		WebSocketPeer.STATE_CLOSING:
			close_connection()


func messaging():
	var bytes = socket.get_available_packet_count( )
	if bytes == 0 : return
	var message = socket.get_packet().get_string_from_utf8 ( )
	var parts = message.split( "\r" )
	for part in parts:
		read_message( part )


func handle_login():
	if login_phase == LoginPhaseEnum.INIT && GameVariables.session_id != "":
		login_phase = LoginPhaseEnum.LOGGING_IN
		log_in_to_session()


func read_message( message ):
	if message == "" : return
	var message_object = JSON.parse_string( message )
	if message_object == null : return

	match( message_object["messageType"] ):
		"GameMeta":
			%GameCode.text = message_object["data"]["gameId"]
			player_color   = message_object["data"]["senderplayer"]["color"]
			user_key       = message_object["data"]["senderplayer"]["userKey"]
			phase          = GamePhaseEnum.PLAYING
		"GameState":
			%PrivateGameWaitingPanel.visible = false
			var recieved_game_state = JSON.stringify( message_object["data"] )
			if recieved_game_state != raw_game_state:
				parse_game_state( message_object["data"] )
				raw_game_state = recieved_game_state
		"Alive":
			%RedTimeLabel.text = Time.get_time_string_from_unix_time ( message_object["data"]["timeControl"]["red"] / 1000 )
			%BlueTimeLabel.text = Time.get_time_string_from_unix_time ( message_object["data"]["timeControl"]["blue"] / 1000 )
			$Timeout.stop()
		"PlayerProfiles":
			parse_player_profiles( message_object["data"] )
		"MoveList":
			parse_move_list( message_object["data"] )


func _on_alive_timer_timeout():
	var message = '{ "messageType" : "Alive", "user" : "%s", "data" : {} }\r' % user_key
	socket.send_text(message)
	$Timeout.start(1)


func _on_timeout_timeout():
	close_connection()


func close_connection():
	connecting_time = 0
	print("Session lost")


func parse_game_state( state : Dictionary ):
	%PieceSound.play()
	for piece in %Pieces.get_children():
		piece.marked_for_deletion = true
	%RedBox.refresh_content(state["redBox"])
	%BlueBox.refresh_content(state["blueBox"])
	%Board.refresh_content(state["board"])
	%MoveCounter.text = str( state["move"] )
	%ActPlayer.text = tr( state["actualPlayer"] )
	$"..".show_take_markers( state["takeMarkers"] )
	if state.has("winner"): 
		%GameResultBoard.visible = true
		if player_color == state["winner"]:
			%ResultLabel.text = "You win"
		else:
			%ResultLabel.text = "You lost"
		phase = GamePhaseEnum.ENDING
	
	for piece in %Pieces.get_children():
		if piece.marked_for_deletion:
			piece.queue_free()



func piece_selected( container, tile ):
	var message = '{ "messageType" : "PieceSelected",
					 "user" : "%s",
					 "data" : { "container" : "%s", "tile" : { "x": %d, "y": %d } } }\r' % [ user_key, container, tile.x, tile.y ]
	socket.send_text(message)


func parse_move_list( moves ):
	if %Pointer.hand == null : return
	
	if moves["piece"]["container"] != %Pointer.hand.container: return
	if moves["piece"]["tile"]["x"] != %Pointer.hand.tile.x : return
	if moves["piece"]["tile"]["y"] != %Pointer.hand.tile.y : return

	for child in %MoveMarkers.get_children():
		child.queue_free()
	
	for move in moves["moves"]:
		var marker = Sprite2D.new()
		marker.texture = load( "res://Textures/Light.png" )
		marker.modulate = Color.GREEN
		%MoveMarkers.add_child( marker )
		marker.global_position = %Board.global_position +  %Board.map_to_local( Vector2i( move["x"], move["y"] ) )
	pass


func move_requested( container, tile ):
	if %Pointer.hand == null : return
	if phase != GamePhaseEnum.PLAYING : return
	
	var message = '{ "messageType" : "MoveRequested",  "user" : "%s", "data" : {
		 "piece":
			{ "container" : "%s", "tile" : { "x": %d, "y": %d } } , 
		"target":
			{ "container" : "%s", "tile" : { "x": %d, "y": %d } } } }\r' % [ 
				user_key,
				%Pointer.hand.container,
				%Pointer.hand.tile.x,
				%Pointer.hand.tile.y,
				container,
				tile.x, 
				tile.y ]
	socket.send_text(message)


func log_in_to_session():
	var message = '{ "messageType" : "SessionLogin",  "user" : "%s", "data" : {
		 "sessionKey" : "%s"} }\r' % [ 
				user_key,
				GameVariables.session_id ]
	socket.send_text(message)


func parse_player_profiles( data ):
	login_phase = LoginPhaseEnum.LOGGED_IN
	if data.has("blue"):
		%BluePlayerName.text = "%s (%s)" % [ data["blue"]["username"], data["blue"]["elo"]]
	if data.has("red"):
		%RedPlayerName.text = "%s (%s)" % [ data["red"]["username"], data["red"]["elo"]]
