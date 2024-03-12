@tool
class_name Equipment
extends Attachable

enum MATERIAL { NONE, LEATHER, CHAIN_MAIL, PLATED  }
enum TYPE { HEAD, BODY, ACCESSORY }

## Reduction of incoming damage 
@export var protection: int = 10

## Used for comp of avoid rate
@export var avoid: int = 0

## Material of the equipment
@export var material = MATERIAL.NONE

## Type of the equipment
@export var type = TYPE.ACCESSORY
