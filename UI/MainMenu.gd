extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_exit_pressed():
	get_tree().quit()


func _on_button_find_games_pressed():
	get_tree().change_scene_to_file("res://SessionList.tscn")


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
