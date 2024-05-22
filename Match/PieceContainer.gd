extends TileMap
class_name PieceContainer

@export var container_name : String

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func refresh_content( content ):
	for piece_data in content:
		refresh_piece( piece_data )


func refresh_piece( piece_data ):
	var coordinates = Vector2i( piece_data.pos.x, piece_data.pos.y )
	for piece in %Pieces.get_children():
		if piece.container == container_name && piece.tile == coordinates :
			piece.marked_for_deletion = false
			return
	
	var piece_node = get_parent().find_child("Pieces")
	var player_color = Color.RED
	if piece_data.owner == "blue" : player_color = Color.BLUE
	var piece = Piece.get_piece( piece_data.type, player_color )
	piece.global_position = global_position + map_to_local( coordinates )
	piece_node.add_child( piece )
