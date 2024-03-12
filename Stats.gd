## Static stats of a unit

class_name Stats
extends Resource

## Distance to which the unit can walk in cells.
@export var move_range: int = 6

## Base strength used for damage calculation
@export var strength: int = 10

## Base defensed used for damage taken calculation
@export var defense: int = 10

## Total health of the unit
@export var health: int = 10

## Used in comp of chance that an attack will land
## and for critical hits
@export var dexterity: int = 10

## Used in comp of chance of avoiding an attack
## and for number of times unit will attack 
@export var speed: int = 10

## Used in comp for critical hit and loot on kill chance
@export var luck: int = 10
