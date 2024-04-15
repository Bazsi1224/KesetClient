extends Node2D
class_name Piece

@export var player_color : Color

var markers = []
var is_selected = false

var container
var tile

const HEX_SIDES = [ 
	TileSet.CELL_NEIGHBOR_RIGHT_SIDE, 
	TileSet.CELL_NEIGHBOR_TOP_RIGHT_SIDE, 
	TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_SIDE, 
	TileSet.CELL_NEIGHBOR_LEFT_SIDE,
	TileSet.CELL_NEIGHBOR_TOP_LEFT_SIDE,
	TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_SIDE,
	 ]

const PIECE_SCENES = {
	"spearman"  : preload("res://Pieces/Spearman.tscn"),
	"mercenary" : preload("res://Pieces/Mercenary.tscn"),
	"knight"    : preload("res://Pieces/Knight.tscn"),
	"thief"     : preload("res://Pieces/Thief.tscn"),
	"archer"    : preload("res://Pieces/Archer.tscn"),
	"engineer"  : preload("res://Pieces/Engineer.tscn"),
	"king"      : preload("res://Pieces/King.tscn"),
}


static func get_piece( piece_type : String, player_color : Color ):
	var piece_scene = PIECE_SCENES[piece_type]
	var piece = PIECE_SCENES[piece_type].instantiate()
	piece.player_color = player_color
	return piece


func _process(_delta):
	$Sprite.material.set_shader_parameter( "PlayerColor", player_color )


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
	sprite.texture = preload("res://Textures/Light.png")
	sprite.modulate = Color.GREEN
	sprite.global_position = tile_map.map_to_local( marker_pos )
	tile_map.add_child( sprite )
	markers.append( sprite )

