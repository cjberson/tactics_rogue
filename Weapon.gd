@tool
class_name Weapon
extends Attachable

enum TYPE { SLASHING, PIERCING, BLUDGEONING, MAGIC }

## Base damage points dealt 
@export var damage: int = 10

## Number of tiles away that can be reached
@export var attack_range: int = 1

## Type of damage dealt 
@export var type = TYPE.SLASHING
