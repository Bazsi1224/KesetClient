extends Node2D

const TAKE_MARKER = preload("res://Match/TakeMarker.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	%Pointer.piece_selected.connect( $NetworkClient.piece_selected )
	%Pointer.move_requested.connect( $NetworkClient.move_requested )


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	set_piece_tiles()
	display_actual_player( %ActPlayer.text )


func set_piece_tiles():
	var pieces     = %Pieces.get_children()
	var used_tiles = null
	var tile       = null
	
	for piece in pieces:
		used_tiles = %Board.get_used_cells(0)
		tile = %Board.local_to_map( piece.global_position - %Board.global_position )
		if used_tiles.has( tile ):
			piece.tile      = tile
			piece.container = "board"
			
		used_tiles = %RedBox.get_used_cells(0)
		tile = %RedBox.local_to_map( piece.global_position - %RedBox.global_position )
		if used_tiles.has( tile ):
			piece.tile      = tile
			piece.container = "redBox"
			
		used_tiles = %BlueBox.get_used_cells(0)
		tile = %BlueBox.local_to_map( piece.global_position - %BlueBox.global_position )
		if used_tiles.has( tile ):
			piece.tile      = tile
			piece.container = "blueBox"


func _on_button_back_pressed():
	$NetworkClient.close_connection()
	get_tree().change_scene_to_file("res://UI/MainMenu.tscn")


func display_actual_player( actualPlayer ):
	if actualPlayer == "red":
		var style_box = StyleBoxFlat.new()
		style_box.bg_color = Color.WHEAT
		%RedPlayerPanel.add_theme_stylebox_override( "panel", style_box)
		style_box = StyleBoxFlat.new()
		style_box.bg_color = Color.TRANSPARENT
		%BluePlayerPanel.add_theme_stylebox_override( "panel",style_box )
	else:
		var style_box = StyleBoxFlat.new()
		style_box.bg_color = Color.TRANSPARENT
		%RedPlayerPanel.add_theme_stylebox_override( "panel", style_box)
		style_box = StyleBoxFlat.new()
		style_box.bg_color = Color.WHEAT
		%BluePlayerPanel.add_theme_stylebox_override( "panel",style_box )


func _on_button_copy_pressed():
	DisplayServer.clipboard_set( %GameCode.text )


func show_take_markers( markers ):
	for marker in %TakeMarkers.get_children():
		marker.queue_free()
	for take in markers:
		var coordinates = Vector2i( take.x, take.y )
		var marker = TAKE_MARKER.instantiate()
		marker.global_position = %Board.map_to_local( coordinates )
		%TakeMarkers.add_child( marker )


func _on_button_pressed():
	get_tree().change_scene_to_file( "res://UI/MainMenu.tscn" )
