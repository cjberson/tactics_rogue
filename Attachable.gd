@tool
class_name Attachable
extends Resource

## Used for comp of hit rate
@export var hit: int = 10

## Used for comp of crit rate
@export var crit: int = 10

## Used for comp of avoid and crit avoid
@export var luck: int = 10

## Image for GUI
@export var icon: Texture

## Total durability 
@export var durability: int = 10

## Higher weight decreases attack speed
@export var weight: int = 10

## Remaining durability
var remaining_durability: int


func _enter_tree() -> void:
	remaining_durability = durability
