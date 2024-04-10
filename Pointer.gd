extends Marker2D

var tile
var hand

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	move_marker()
	tile = %TileMap.local_to_map( global_position )


func move_marker():
	var viewport = get_viewport()
	var used_cells = %TileMap.get_used_cells(0)
	var mouse_tile = viewport.get_mouse_position()
	mouse_tile -= Vector2( viewport.size.x / 2, viewport.size.y / 2 )
	mouse_tile =  %TileMap.local_to_map( mouse_tile )
	if( used_cells.has( mouse_tile ) ):
		visible = true
		global_position =  %TileMap.map_to_local( mouse_tile )
	else:
		visible = false



func _unhandled_input(event):
	if event is InputEventMouseButton:
		for piece in get_parent().pieces:
			piece.deselect()
		if event.pressed:
			for piece in get_parent().pieces:
				if piece.tile == tile:
					piece.select(%TileMap)
					hand = piece
		else:
			if hand != null:
				var previous_tile =  %TileMap.local_to_map( hand.global_position )
				hand.global_position = %TileMap.map_to_local( tile )
				%Debug.text = "%s -> %s" % [ str( previous_tile ), str( tile ) ]
				hand = null
		
		
