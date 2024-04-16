extends Marker2D

var tile           : Vector2i
var container_name : String
var hand

signal piece_selected( container, tile )
signal move_requested( container, tile )

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	move_marker()
	$PieceSprite.visible = hand != null
	if hand != null : 
		$PieceSprite.texture = hand.find_child("Sprite").texture
		$PieceSprite.material.set_shader_parameter( "PlayerColor", hand.player_color )


func move_marker():
	var viewport  = get_viewport()
	var mouse_pos = viewport.get_mouse_position()
	mouse_pos -= Vector2( viewport.size.x / 2, viewport.size.y / 2 )

	container_name = "no container"
	tile = Vector2i(0 , 0)

	if is_in_container( %RedBox, mouse_pos ):
		set_marker_position( %RedBox, mouse_pos )
	if is_in_container( %BlueBox, mouse_pos ):
		set_marker_position( %BlueBox, mouse_pos )
	if is_in_container( %Board, mouse_pos ):
		set_marker_position( %Board, mouse_pos )

	%Debug.text = str( container_name ) + " " + str( tile )

	visible = (
		is_in_container( %Board, mouse_pos ) or 
		is_in_container( %BlueBox, mouse_pos ) or 
		is_in_container( %RedBox, mouse_pos )
		)


func is_in_container( container, mouse_pos ):
	var used_cells = container.get_used_cells(0)
	var mouse_tile =  container.local_to_map( mouse_pos - container.global_position )
	if( used_cells.has( mouse_tile ) ):
		return true
	else:
		return false


func set_marker_position( container, mouse_pos ):
	$HexSprite.visible = container == %Board
	$SquareSprite.visible = container != %Board
	var mouse_tile =  container.local_to_map( mouse_pos - container.global_position )
	tile = mouse_tile
	container_name = container.container_name
	global_position = container.to_global(container.map_to_local( mouse_tile ))


func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index != MOUSE_BUTTON_LEFT : return
		for piece in %Pieces.get_children():
			piece.deselect()
		if event.pressed:
			for piece in %Pieces.get_children():
				if piece.tile == tile and piece.container == container_name:
					piece_selected.emit( container_name, tile )
					hand = piece
		else:
			if hand != null:
				move_requested.emit( container_name, tile )
			hand = null
			for child in %MoveMarkers.get_children():
				child.queue_free()
