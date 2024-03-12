## Draws a selected unit's walkable tiles.
class_name UnitOverlay
extends TileMap


## Fills the tilemap with the cells, giving a visual representation 
## of the cells a unit can do something.
func draw(source_id_to_cells: Dictionary) -> void:
	clear()
	for source_id in source_id_to_cells:
		var cells = source_id_to_cells[source_id]
		for cell in cells:
			set_cell(0, cell, source_id, Vector2i(0,0))
