extends Node2D

@onready var tile_map: TileMapLayer = $/root/Root/TileMapLayer
var current_tile_data: TileData
@onready var item = get_parent()

const speed = 1;

func _ready():
	pass

func _process(delta: float) -> void:
	current_tile_data = tile_map.get_cell_tile_data(tile_map.local_to_map(tile_map.to_local(item.global_position)))
	if current_tile_data:
		match current_tile_data.get_custom_data("Type"):
			"conveyor":
				if !current_tile_data.flip_h and !current_tile_data.transpose:
					item.position.x += speed
				elif current_tile_data.flip_h and !current_tile_data.transpose:
					item.position.x -= speed
				elif !current_tile_data.flip_v and current_tile_data.transpose:
					item.position.y += speed
				elif current_tile_data.flip_v and current_tile_data.transpose:
					item.position.y -= speed
			_:
				pass
