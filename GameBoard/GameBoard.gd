## Represents and manages the game board. Stores references to entities that are in each cell and
## tells whether cells are occupied or not.
## Units can only move around the grid one at a time.
class_name GameBoard
extends Node2D

enum OVERLAY_ID { MOVE, ATTACK, INTERACT }
enum TURN { PLAYER, OPPONENT }
const DIRECTIONS = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]

## Resource of type Grid.
@export var grid: Resource

## Mapping of coordinates of a cell to a reference to the unit it contains.
var units: Dictionary = {}
var active_unit: Unit
var walkable_cells: Array = []
var attackable_cells: Array = []
var interactable_cells: Array = []

var turn: TURN = TURN.PLAYER

@onready var unit_overlay: UnitOverlay = $UnitOverlay
@onready var unit_path: UnitPath = $UnitPath

## GUI for when a unit is selected
@onready var unit_gui: MarginContainer
@onready var portrait_gui: TextureRect
@onready var name_gui: Label
@onready var health_gui: Label
@onready var health_bar_gui: TextureProgressBar

## GUI for when player is selecting the action 
## a unit makes after moving
@onready var action_gui: MarginContainer
@onready var action_list_gui: VBoxContainer

func _ready() -> void:
	reinitialize()
	set_gui()

func set_gui() -> void:
	## Get all the GUIs 
	portrait_gui = get_node("UnitGUI/PortraitAndDetails/Portrait/Texture")
	name_gui = get_node("UnitGUI/PortraitAndDetails/Details/Name/Label")
	health_gui = get_node("UnitGUI/PortraitAndDetails/Details/Health")
	health_bar_gui = get_node("UnitGUI/PortraitAndDetails/Details/HealthBar/Bar")
	unit_gui = get_node("UnitGUI")
	
	action_gui = get_node("ActionGUI")
	action_list_gui = get_node("ActionGUI/ActionList")
	
	## Hide GUIs by default
	unit_gui.hide()
	action_gui.hide()
	
	
	
func _unhandled_input(event: InputEvent) -> void:
	if active_unit and event.is_action_pressed("ui_cancel"):
		deselect_active_unit()
		clear_active_unit()

func _get_configuration_warning() -> String:
	var warning: String = ""
	if not grid:
		warning = "You need a Grid resource for this node to work."
	return warning


## Returns `true` if the cell is occupied by a unit.
func is_occupied(cell: Vector2) -> bool:
	return units.has(cell)

## Returns an array of cells a given unit can walk using the flood fill algorithm.
func get_walkable_cells(unit: Unit) -> Array:
	return flood_fill_walk(unit.cell, unit.stats.move_range)
	
## Returns an array of cells a given unit can attack using the flood fill algorithm.
func get_attackable_cells(unit: Unit) -> Array:
	var max_attack_range = unit.inventory.get_max_attack_range()
	return flood_fill_with_occupied(unit.cell, max_attack_range)
	
## Returns an array of cells a given unit can attack using the flood fill algorithm.
func get_interactable_cells(unit: Unit) -> Array:
	var adjacent_cells = flood_fill_with_occupied(unit.cell, 1)
	var result = []
	
	## Remove cells that do not have allies in it
	for adjacent_cell in adjacent_cells:
		if is_occupied(adjacent_cell):
			var adjacent_unit: Unit = units[adjacent_cell]
			
			if adjacent_unit.player == unit.player:
				result.append(adjacent_cell)
	
	return result
	
## Clears, and refills the `units` dictionary with game objects that are on the board.
func reinitialize() -> void:
	units.clear()

	for child in get_children():
		var unit: Unit = child as Unit
		if not unit:
			continue
		units[unit.cell] = unit

## Returns an array with all the coordinates of walkable cells based on the `max_distance`.
func flood_fill_walk(cell: Vector2, max_distance: int) -> Array:
	var array: Array = []
	var stack: Array = [cell]
	while not stack.size() == 0:
		var current = stack.pop_back()
		if not grid.is_within_bounds(current) or current in array:
			continue

		var difference: Vector2 = (current - cell).abs()
		var distance: int = int(difference.x + difference.y)
		if distance > max_distance:
			continue
		
		if current != cell:
			array.append(current)
			
		for direction in DIRECTIONS:
			var coordinates: Vector2 = current + direction
			if is_occupied(coordinates) or coordinates in array or coordinates in stack:
				continue

			stack.append(coordinates)
	
	return array
	
## Returns an array with all the coordinates of attackable cells based on the `max_distance`.
func flood_fill_with_occupied(cell: Vector2, max_distance: int) -> Array:
	var array: Array = []
	var stack: Array = [cell]
	while not stack.size() == 0:
		var current = stack.pop_back()
		if not grid.is_within_bounds(current) or current in array:
			continue

		var difference: Vector2 = (current - cell).abs()
		var distance: int = int(difference.x + difference.y)
		if distance > max_distance:
			continue
		
		if current != cell:
			array.append(current)
			
		for direction in DIRECTIONS:
			var coordinates: Vector2 = current + direction
			if coordinates in array or coordinates in stack:
				continue

			stack.append(coordinates)
	
	return array

## Updates the units dictionary with the target position for the unit and asks the active_unit to walk to it.
func move_active_unit(cell: Vector2) -> void:
	if cell in walkable_cells:
		print("Moving")
		
		## Move the unit on internal representation of the board
		units.erase(active_unit.cell)
		units[cell] = active_unit
		
		## Make it so the unit no longer appears selected 
		deselect_active_unit()
		
		## TODO: Disable the mouse, walk, and then reenable the mouse after done walk
		active_unit.walk_along(unit_path.current_path)
		await active_unit.walk_finished

		
		## Display attack range only
		attackable_cells = get_attackable_cells(active_unit)
		unit_overlay.draw({OVERLAY_ID.ATTACK: attackable_cells})
		
		## Display menu for attack (if a unit is in range),
		## item, and wait. 
		unit_gui.hide()
		action_list_gui.show()
		var actions = action_list_gui.get_children() as Array[Label]
		
		clear_active_unit()
	
## Use the active unit to attack the unit in the given cell
func attack_with_active_unit(cell: Vector2) -> void:
	# TODO: change to opening a menu
	var other_unit: Unit = units[cell]
	
	if cell in attackable_cells:
		print("Attacking")
		other_unit.remaining_health -= active_unit.damage
		
		destroy_unit(other_unit)
		deselect_active_unit()
		# TODO: Animation of attack here
		clear_active_unit()
	
## Use the active unit to interact with the unit in the given cell
func interact_with_active_unit(cell: Vector2) -> void:
	# TODO: open menu to trade, pick up if active is a horse, etc.
	var other_unit: Unit = units[cell]
		
	if cell in interactable_cells:
		print("Interacting")
		pass

## Selects the unit in the `cell` if there's one there.
## Sets it as the `active_unit` and draws its walkable cells and interactive move path. 
func select_unit(cell: Vector2) -> void:
	if not units.has(cell):
		return

	var unit: Unit = units[cell]
	
	if unit.player:
		active_unit = unit
		active_unit.is_selected = true
		walkable_cells = get_walkable_cells(active_unit)
		attackable_cells = get_attackable_cells(active_unit)
		interactable_cells = get_interactable_cells(active_unit)
		var source_id_to_cells = {
			OVERLAY_ID.MOVE: walkable_cells, 
			OVERLAY_ID.ATTACK: attackable_cells,
			OVERLAY_ID.INTERACT: interactable_cells
		}
		unit_overlay.draw(source_id_to_cells)
		unit_path.initialize(walkable_cells)
	else:
		# TODO: Show range and stats about enemy unit
		pass

## Deselects the active unit, clearing the cells overlay and interactive path drawing.
func deselect_active_unit() -> void:
	active_unit.is_selected = false
	unit_overlay.clear()
	unit_path.stop()

## Clears the reference to the active_unit and the corresponding walkable and attackable cells.
func clear_active_unit() -> void:
	active_unit = null
	walkable_cells.clear()
	attackable_cells.clear()
	
## Clear references to the unit and then free it
func destroy_unit(unit: Unit) -> void:
	if unit.remaining_health <= 0:
		units.erase(unit.cell)
		unit.queue_free()

## Selects or moves a unit based on where the cursor is.
func _on_Cursor_accept_pressed(cell: Vector2) -> void:
	## If no unit is active, select one if there is one
	if not active_unit:
		select_unit(cell)
	## Otherwise, if there is a unit selected, move if in range
	elif active_unit.is_selected:
		if is_occupied(cell):
			if active_unit.player != units[cell].player:
				attack_with_active_unit(cell)
			else:
				interact_with_active_unit(cell)
		## Otherwise, the cell is not occupied, so move if in range
		else:
			move_active_unit(cell)

## Updates the interactive path's drawing if there's an active and selected unit.
func _on_Cursor_moved(new_cell: Vector2) -> void:
	if active_unit and active_unit.is_selected:
		unit_path.draw(active_unit.cell, new_cell)
	elif is_occupied(new_cell):
		var unit: Unit = units[new_cell]
		portrait_gui.texture = unit.portrait
		name_gui.text = unit.name
		health_gui.text = str(unit.remaining_health) + "/" + str(unit.stats.health)
		var health_bar_value = (1.0 * unit.remaining_health / unit.stats.health) * 100
		health_bar_gui.value = health_bar_value
		unit_gui.show()
	else:
		unit_gui.hide()
