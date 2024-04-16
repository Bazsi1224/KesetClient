extends Node
var socket = StreamPeerTCP.new()
var port : int
var connecting_time = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	socket.poll()
	var status = socket.get_status()
	match( status ):
		StreamPeerTCP.STATUS_NONE :
			var error = socket.connect_to_host( "localhost", port )
			$AliveTimer.start(1)
		StreamPeerTCP.STATUS_CONNECTING:
			connecting_time += delta
			if connecting_time > 5 : 
				close_connection()
		StreamPeerTCP.STATUS_CONNECTED :
			messaging()
		StreamPeerTCP.STATUS_ERROR:
			close_connection()


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
		"GameState":
			parse_game_state( message_object["data"] )
		"Alive":
			$Timeout.stop()
		"MoveList":
			parse_move_list( message_object["data"] )


func _on_alive_timer_timeout():
	var message = '{ "messageType" : "Alive", "data" : {} }\r'
	socket.put_utf8_string(message)
	$Timeout.start(1)


func _on_timeout_timeout():
	close_connection()


func close_connection():
	$"../SessionFinder".process_mode = Node.PROCESS_MODE_ALWAYS
	process_mode = Node.PROCESS_MODE_DISABLED
	connecting_time = 0
	print("Session lost")


func parse_game_state( state ):
	for piece in %Pieces.get_children():
		piece.queue_free()
	%RedBox.refresh_content(state["redBox"])
	%BlueBox.refresh_content(state["blueBox"])
	%Board.refresh_content(state["board"])


func piece_selected( container, tile ):
	var message = '{ "messageType" : "PieceSelected", "data" : { "container" : "%s", "tile" : { "x": %d, "y": %d } } }\r' % [ container, tile.x, tile.y ]
	socket.put_utf8_string(message)


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
	
	var message = '{ "messageType" : "MoveRequested", "data" : {
		 "piece":
			{ "container" : "%s", "tile" : { "x": %d, "y": %d } } , 
		"target":
			{ "container" : "%s", "tile" : { "x": %d, "y": %d } } } }\r' % [ 
				%Pointer.hand.container,
				%Pointer.hand.tile.x,
				%Pointer.hand.tile.y,
				container,
				tile.x, 
				tile.y ]
	socket.put_utf8_string(message)
	
