class_name IncLifeAffix
extends AffixDefinition

var min_value := 10
var max_value := 40

func can_apply_to(_item: Item) -> bool:
	return true

func roll(_item: Item) -> AffixInstance:
	var value := randi_range(min_value, max_value)
	return AffixInstance.new(id, [value])
