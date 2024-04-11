extends Node
var socket = StreamPeerTCP.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	socket.poll()
	var status = socket.get_status()
	match( status ):
		StreamPeerTCP.STATUS_NONE :
			var error = socket.connect_to_host( "localhost", 51224 )
			$AliveTimer.start(1)
		StreamPeerTCP.STATUS_CONNECTED :
			messaging()


func messaging():
	var bytes = socket.get_available_bytes( )
	if bytes == 0 : return
	var message = socket.get_utf8_string(bytes)
	var parts = message.split( "\r" )
	for part in parts:
		print( part )


func _on_alive_timer_timeout():
	var message = "Alive"
	socket.put_utf8_string( message )
