extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var pieces     = $Pieces.get_children()
	var used_tiles = null
	var tile       = null
	
	for piece in pieces:
		used_tiles = %Board.get_used_cells(0)
		tile = %Board.local_to_map( piece.global_position )
		if used_tiles.has( tile ):
			piece.tile      = tile
			piece.container = "board"
			
		used_tiles = %RedBox.get_used_cells(0)
		tile = %RedBox.local_to_map( piece.global_position )
		if used_tiles.has( tile ):
			piece.tile      = tile
			piece.container = "blueBox"
		
		used_tiles = %BlueBox.get_used_cells(0)
		tile = %BlueBox.local_to_map( piece.global_position )
		if used_tiles.has( tile ):
			piece.tile      = tile
			piece.container = "redBox"
