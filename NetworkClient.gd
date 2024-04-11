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
			print("GameState received")
			pass
		"Alive":
			$Timeout.stop()
			print("Alive received")


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


