extends Node2D

var pieces = []


# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_children():
		if child is Piece:
			pieces.append( child )



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	for piece in pieces:
		piece.tile = %TileMap.local_to_map( piece.global_position )
