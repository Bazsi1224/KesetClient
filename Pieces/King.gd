extends Piece

const MOVE_DISTANCE = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$Sprite.material.set_shader_parameter( "PlayerColor", player_color )


func cast_possible_moves( tile_map ):
	var tile = tile_map.local_to_map( global_position )
	var used_cells : Array = tile_map.get_used_cells( 0 )
	for direction in HEX_SIDES:
		var neighbor = tile_map.get_neighbor_cell ( tile, direction  ) 
		for distance in range(MOVE_DISTANCE):
			if used_cells.has( neighbor ):
				cast_marker( neighbor, tile_map )
			else:
				break
			neighbor = tile_map.get_neighbor_cell ( neighbor, direction  )
