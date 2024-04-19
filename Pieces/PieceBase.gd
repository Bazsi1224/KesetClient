extends Node2D
class_name Piece

@export var player_color : Color

var markers = []
var is_selected = false

var container
var tile

const PIECE = preload("res://Pieces/Piece.tscn")

const PIECE_TEXTURES= {
	"spearman"  : preload("res://Pieces/Spearman.png"),
	"mercenary" : preload("res://Pieces/Mercenary.png"),
	"knight"    : preload("res://Pieces/Knight.png"),
	"thief"     : preload("res://Pieces/Thief.png"),
	"archer"    : preload("res://Pieces/Archer.png"),
	"engineer"  : preload("res://Pieces/Engineer.png"),
	"king"      : preload("res://Pieces/King.png"),
}


static func get_piece( piece_type : String, player_color : Color ):
	var piece = PIECE.instantiate()
	piece.player_color = player_color
	piece.find_child("Sprite").texture = PIECE_TEXTURES[ piece_type ]
	piece.find_child("Sprite").material.set_shader_parameter( "PlayerColor", player_color )
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

