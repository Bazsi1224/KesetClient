extends Control

enum AuthStepsEnum { INITIAL, GET_SALTS, WAIT_SALTS, LOGGING_IN }

var socket = WebSocketPeer.new()
var step = AuthStepsEnum.INITIAL
var pass_phrase : String

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	socket.poll()
	var status = socket.get_ready_state()
	
	match( status ):
		WebSocketPeer.STATE_CLOSED :
			if step != AuthStepsEnum.INITIAL:
				var error = socket.connect_to_url("wss://baldheadgames.hu:47562")
		WebSocketPeer.STATE_CONNECTING :
			pass
		WebSocketPeer.STATE_OPEN :
			match( step ):
				AuthStepsEnum.GET_SALTS:
						var message = '{ "messageType" : "GetSalts", "user" : "%s" }\r' % %Username.text
						socket.send_text(message)
						step = AuthStepsEnum.WAIT_SALTS
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
		"GetSalts":
			salt_request_completed( message_object )
		"Login":
			login_completed( message_object )
			


func _on_button_pressed():
	step = AuthStepsEnum.GET_SALTS
	


func salt_request_completed( message_object ):
	if message_object["result"] != "SUCCESS":
		%Message.text = message_object["result"]
		%Password.text = ""
		step = AuthStepsEnum.INITIAL
		return
	
	var salt = message_object["salt"]
	
	var salted_pass = %Password.text + salt
	
	var hashing = HashingContext.new()
	hashing.start(HashingContext.HASH_SHA256)
	hashing.update(salted_pass.to_utf8_buffer() )
	var hash = hashing.finish().hex_encode()
	
	hash += message_object["oneTimeKey"]
	hashing.start(HashingContext.HASH_SHA256)
	hashing.update( hash.to_utf8_buffer() )
	pass_phrase = hashing.finish().hex_encode()
	
	var message = '{ "messageType" : "Login", "user" : "%s", "PassPhrase" : "%s" }\r' % [
		%Username.text,
		pass_phrase
		]
	socket.send_text(message)
	step = AuthStepsEnum.LOGGING_IN


func login_completed(message_object):
	if message_object["result"] != "SUCCESS":
		%Message.text = message_object["result"]
	else:
		%LoginGroup.visible    = false
		%LoggedInGroup.visible = true
		GameVariables.username = message_object["user"]
		%LoggedInUsername.text = message_object["user"]
		GameVariables.session_id = message_object["sessionKey"]
		%Message.text = ""
	%Password.text = ""
	step = AuthStepsEnum.INITIAL


func _on_logout_button_pressed():
	%LoginGroup.visible    = true
	%LoggedInGroup.visible = false
	GameVariables.username = 'Guest'
	%LoggedInUsername.text = ''
	%Message.text = ""
	step = AuthStepsEnum.INITIAL


func _on_username_text_submitted(new_text):
	%Password.grab_focus()


func _on_password_text_submitted(new_text):
	step = AuthStepsEnum.GET_SALTS


func _on_username_focus_entered():
	DisplayServer.virtual_keyboard_show( %Username.text )


func _on_password_focus_entered():
	DisplayServer.virtual_keyboard_show( %Password.text )


func _on_focus_exited():
	DisplayServer.virtual_keyboard_hide( )

