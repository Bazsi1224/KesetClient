extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if $SessionFinder.online :
		%ButtonFindGames.disabled = false
		%ButtonPrivateGame.disabled = false
		%ButtonJoinPrivate.disabled = false
		%OnlineState.text = tr( "Online" )
	else:
		%ButtonFindGames.disabled = true
		%ButtonPrivateGame.disabled = true
		%ButtonJoinPrivate.disabled = true
		%OnlineState.text = tr( "Offline" )
	
	%JoinGameId.text = %JoinGameId.text.to_upper()
	%JoinGameId.caret_column = %JoinGameId.text.length()


func _on_button_exit_pressed():
	get_tree().quit()


func _on_button_back_pressed():
	%PrivateGameWaitingPanel.visible = false


func _on_button_private_game_pressed():
	var player_color = "random"
	match( %PrivateSelectedColor.selected ) :
		0: player_color = "random"
		1: player_color = "red"
		2: player_color = "blue"
	$SessionFinder.start_private_game( player_color )


func _on_button_join_private_pressed():
	$SessionFinder.join_private_game( %JoinGameId.text )

func _on_button_find_games_pressed():
	$SessionFinder.join_public_game( )

func _on_join_game_id_text_submitted(new_text):
	$SessionFinder.join_private_game( %JoinGameId.text )
