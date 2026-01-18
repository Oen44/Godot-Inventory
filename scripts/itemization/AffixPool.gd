class_name AffixPool
extends Control
## A pool of affix definitions to roll from.

@export var affixes_path: String = "res://items/affixes/"

var affixes: Dictionary[String, AffixDefinition] = {}

func roll_affix_count(item: Item) -> int:
	var candidates := get_affixes_for(item)
	if candidates.is_empty():
		return 0

	return randi_range(0, min(4, candidates.size()))

## Rolls an affix for the given item, returning an AffixInstance or null if none can be applied.
func roll_affix(item: Item) -> AffixInstance:
	var candidates := get_affixes_for(item)

	if candidates.is_empty():
		return null

	var selected := _weighted_pick(candidates)
	return selected.roll(item)

## Performs a weighted random selection from a list of AffixDefinitions.
func _weighted_pick(list: Array[AffixDefinition]) -> AffixDefinition:
	var total := 0
	for a in list:
		total += a.weight

	var roll := randi_range(1, total)
	for a in list:
		roll -= a.weight
		if roll <= 0:
			return a

	return list[0]

## Loads all AffixDefinition resources from the items_path + "/affixes/" directory.
func load_affixes():
	var dir = DirAccess.open(affixes_path)
	if not dir:
		push_error("Failed to open affixes directory.")
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()
	while not file_name.is_empty():
		if dir.current_is_dir():
			file_name = dir.get_next()
			continue

		if file_name.ends_with(".tres") or file_name.ends_with(".res"):
			var affix_path = affixes_path + file_name
			var affix_resource = ResourceLoader.load(affix_path)
			if affix_resource and affix_resource is AffixDefinition:
				affixes[affix_resource.id] = affix_resource
			else:
				push_warning("Failed to load AffixDefinition from %s" % affix_path)

		file_name = dir.get_next()

	dir.list_dir_end()
	print("Loaded %d affixes." % affixes.size())

## Retrieves an affix definition by its ID.
func get_affix(affix_id: String) -> AffixDefinition:
	return affixes.get(affix_id)

## Retrieves all affixes that can be applied to the given item.
func get_affixes_for(item: Item) -> Array[AffixDefinition]:
	var result: Array[AffixDefinition] = []
	for affix_id in affixes:
		var affix = affixes[affix_id]

		if not affix.enabled:
			continue
		
		if item.has_affix(affix_id):
			continue

		if affix.can_apply_to(item):
			result.append(affix)
	return result
