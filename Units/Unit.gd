## Represents a unit on the game board.
## The board manages its position inside the game grid.
## The unit itself holds stats and a visual representation that moves smoothly in the game world.
@tool
class_name Unit
extends Path2D

## Emitted when the unit reached the end of a path along which it was walking.
signal walk_finished

## Shared resource of type Grid, used to calculate map coordinates.
@export var grid: Resource

@export var stats: Stats = Stats.new()

## The unit's move speed when it's moving along a path.
@export var move_speed: float = 600.0

## deprecated
@export var damage: int = 1

## Image for GUI
@export var portrait: Texture

## Invetory of the unit
@export var inventory: Inventory = Inventory.new()

## Flag for whether the unit is controller by the player
@export var player: bool = false

## Health the unit has left starting at full
var remaining_health: int 

## Texture representing the unit.
@export var skin: Texture:
	set(value):
		skin = value
		if not sprite:
			# This will resume execution after this node's _ready()
			await ready
		sprite.texture = value
		
## Offset to apply to the `skin` sprite in pixels.
@export var skin_offset: Vector2 = Vector2.ZERO:
	set(value):
		skin_offset = value
		if not sprite:
			await ready
		sprite.position = value

## Coordinates of the current cell the cursor moved to.
var cell: Vector2 = Vector2.ZERO:
	set(value):
		# When changing the cell's value, we don't want to allow coordinates outside
		#	the grid, so we clamp them
		cell = grid.grid_clamp(value)
		
## Toggles the "selected" animation on the unit.
var is_selected: bool = false:
	set(value):
		is_selected = value
		if is_selected:
			anim_player.play("selected")
		else:
			anim_player.play("idle")

var is_walking: bool = false:
	set(value):
		is_walking = value
		set_process(is_walking)

@onready var sprite: Sprite2D = $PathFollow2D/Sprite
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var path_follow: PathFollow2D = $PathFollow2D

func _enter_tree() -> void:
	remaining_health = stats.health

func _ready() -> void:
	set_process(false)
	path_follow.rotates = false

	cell = grid.calculate_grid_coordinates(position)
	position = grid.calculate_map_position(cell)

	# We create the curve resource here because creating it in the editor prevents us from
	# moving the unit.
	if not Engine.is_editor_hint():
		curve = Curve2D.new()


func _process(delta: float) -> void:
	path_follow.progress += move_speed * delta

	if path_follow.progress_ratio >= 1.0:
		is_walking = false
		# Setting this value to 0.0 causes a Zero Length Interval error
		path_follow.progress = 0.00001
		position = grid.calculate_map_position(cell)
		curve.clear_points()
		emit_signal("walk_finished")


## Starts walking along the `path`.
## `path` is an array of grid coordinates that the function converts to map coordinates.
func walk_along(path: PackedVector2Array) -> void:
	if path.is_empty():
		return

	curve.add_point(Vector2.ZERO)
	for point in path:
		curve.add_point(grid.calculate_map_position(point) - position)
	cell = path[-1]
	is_walking = true
	
## Gets the chance that this unit will hit with the weapon
## at the given index
func get_hit(weapon_index: int) -> int:
	return inventory.get_hit(weapon_index) + stats.dexterity

## Gets the amount of raw damage that this unit would do
## with the weapon at the given index
func get_damage(weapon_index: int) -> int:
	var weapon_damage = inventory.get_damage(weapon_index)
	return stats.strength + weapon_damage
	
func get_defense() -> int:
	var protection = inventory.get_protection()
	return stats.defense + protection
	
## Gets the value that determines how many times the unit will attack
func get_attack_speed(weapon_index: int) -> int:
	var weight = inventory.get_weight(weapon_index) 
	var speed_reduction = max(0, weight - ceil(stats.strength / 5.0))
	return stats.speed - speed_reduction
	
## Gets the value that partially determines if the unit will crit
## and if you can avoid a crit
func get_luck(weapon_index: int) -> int:
	var equipment_luck = inventory.get_luck(weapon_index)
	return stats.luck + equipment_luck
	
## Gets the value that determines if the attack will be a crit
func get_crit(weapon_index: int) -> int:
	var crit = inventory.get_crit(weapon_index)
	var luck = get_luck(weapon_index)
	return crit + round((stats.dexterity + luck) / 2.0)
	
## Gets the value that determines if the unit will avoid an attack
func get_avoid(weapon_index:int) -> int:
	var attack_speed = get_attack_speed(weapon_index)
	return (attack_speed + stats.luck) / 2
