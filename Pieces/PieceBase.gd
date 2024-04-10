extends Node2D
class_name Piece

@export var player_color : Color

var markers = []
var is_selected = false
var tile

const HEX_SIDES = [ 
	TileSet.CELL_NEIGHBOR_RIGHT_SIDE, 
	TileSet.CELL_NEIGHBOR_TOP_RIGHT_SIDE, 
	TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_SIDE, 
	TileSet.CELL_NEIGHBOR_LEFT_SIDE,
	TileSet.CELL_NEIGHBOR_TOP_LEFT_SIDE,
	TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_SIDE,
	 ]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func select(tile_map):
	if is_selected : return
	cast_possible_moves(tile_map)
	is_selected = true


func deselect():
	for marker in markers:
		marker.queue_free()
	markers.clear()
	is_selected = false


func cast_possible_moves(tile_map):
	pass


func cast_marker( marker_pos, tile_map ):
	var sprite = Sprite2D.new()
	sprite.texture = preload("res://Light.png")
	sprite.modulate = Color.GREEN
	sprite.global_position = tile_map.map_to_local( marker_pos )
	tile_map.add_child( sprite )
	markers.append( sprite )
