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
	var piece_node = get_parent().find_child("Pieces")
	
	for piece_data in content:
		var player_color = Color.RED
		if piece_data.owner == "blue" : player_color = Color.BLUE
		
		var piece = Piece.get_piece( piece_data.type, player_color )
		var coordinates = Vector2i( piece_data.pos.x, piece_data.pos.y )
		piece.global_position = global_position + map_to_local( coordinates )
		piece_node.add_child( piece )
