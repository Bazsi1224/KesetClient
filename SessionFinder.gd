extends Node
var socket = StreamPeerTCP.new()

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
	
	if message_object["messageType"] == "SessionOpen":
		$"../NetworkClient".port = message_object["data"]["port"]
		$"../NetworkClient".process_mode = Node.PROCESS_MODE_ALWAYS
		process_mode = Node.PROCESS_MODE_DISABLED
