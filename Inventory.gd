@tool
class_name Inventory
extends Resource

@export var usable_weapons: Array[Weapon.TYPE] = []
@export var weapons: Array[Weapon] = []

@export var usable_equipment_materials: Array[Equipment.MATERIAL] = []
@export var body_equipment: Equipment = null
@export var head_equipment: Equipment = null

@export var accessory_limit: int = 1
@export var accessories: Array[Equipment] = []

func get_protection() -> int:
	var result = 0
	
	for equipment in get_equipment():
		result += equipment.protection
		
	return result
	
func get_max_attack_range() -> int:
	## If unit has no weapons, return 1 to avoid crash
	if weapons.is_empty():
		return 1
	
	return weapons.map(func(w: Weapon): return w.attack_range).max()

## Getters that sum up stats for current weapon and all equipment

func get_hit(weapon_index: int) -> int:
	return get_sum(weapon_index, 'hit')
	
func get_damage(weapon_index: int) -> int:
	return get_sum(weapon_index, 'damage')
	
func get_weight(weapon_index: int) -> int:
	return get_sum(weapon_index, 'weight')
	
func get_avoid(weapon_index: int) -> int:
	return get_sum(weapon_index, 'avoid')
	
func get_crit(weapon_index: int) -> int:
	return get_sum(weapon_index, 'crit')
	
func get_luck(weapon_index: int) -> int:
	return get_sum(weapon_index, 'luck')
	
## Helper functions that simplify collection of stats from inventory	

func get_equipment() -> Array[Equipment]:
	var result = []
	
	if body_equipment:
		result.append(body_equipment)
		
	if head_equipment:
		result.append(head_equipment)
		
	for accessory in accessories:
		result.append(accessory)
		
	return result
	
func get_sum(weapon_index: int, name: String) -> int:
	var result = 0
	
	if name in weapons[weapon_index]:
		result += weapons[weapon_index][name] 
	
	for equipment in get_equipment():
		if name in equipment[name]:
			result += equipment[name]
		
	return result
	


