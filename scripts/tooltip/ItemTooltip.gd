extends Control
## Displays a tooltip for an item when hovered over.
##
## Shows item name, description, stats, etc.

@export var hbox_container: HBoxContainer
@export_group("Current Item")
@export var container_current: Control
@export var margin_container_current: MarginContainer
@export_group("Equipped Item")
@export var equipped_panel: Control
@export var container_equipped: Control
@export var margin_container_equipped: MarginContainer

@export var max_width: int = 300
@export var default_label: PackedScene = preload("res://scripts/tooltip/sections/labels/DefaultTooltipLabel.tscn")
@export var advanced_shortcut: Shortcut

var _current_item: InventoryItem = null
var show_advanced: bool = false

var sections: Array[TooltipSection] = [
	EquippedSection.new(),
	NameSection.new(),
	SlotSection.new(),
	BaseStatsSection.new(),
	AffixesSection.new(),
	DescriptionSection.new(),
	PriceSection.new()
]

func _ready():
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 10
	get_parent().call_deferred("remove_child", self)
	get_parent().call_deferred("add_child", canvas_layer)
	canvas_layer.call_deferred("add_child", self)

func _unhandled_key_input(event):
	if not event.is_echo() and advanced_shortcut.matches_event(event):
		if show_advanced != event.pressed:
			show_advanced = event.pressed
			if _current_item:
				inspect(_current_item)

func close():
	visible = false
	equipped_panel.visible = false
	_current_item = null

func inspect(inventory_item: InventoryItem) -> void:
	equipped_panel.visible = false
	visible = true
	_current_item = inventory_item

	for child in container_current.get_children():
		child.free()

	var item = inventory_item.item
	for section in sections:
		if section.applies_to(item):
			section.append(item, self)

	if margin_container_current:
		size.y = margin_container_current.get_theme_constant("margin_top") + margin_container_current.get_theme_constant("margin_bottom")

	var equipment: EquipmentModel = InventorySystem.get_equipment()
	if equipment:
		var equipped_item = equipment.get_item_at(item.base.slot_type)
		if equipped_item and item != equipped_item:
			equipped_panel.visible = true
			for child in container_equipped.get_children():
				child.free()
			
			for section in sections:
				if section.applies_to(equipped_item):
					section.append(equipped_item, self)
					
	reset_size()
	display(inventory_item.get_global_rect())

func display(rect: Rect2):
	var new_pos = rect.position + Vector2(rect.size.x + 5, 0)
	var screen_size = get_viewport_rect().size
	if new_pos.x + size.x > screen_size.x:
		new_pos.x = rect.position.x - size.x - 5
		equipped_panel.get_parent().move_child(equipped_panel, 0)
	else:
		equipped_panel.get_parent().move_child(equipped_panel, 1)
	if new_pos.y + size.y > screen_size.y:
		new_pos.y = screen_size.y - size.y
	
	global_position = new_pos

func add_line(text: String, label_path: String = "") -> void:
	var label_instance = null
	
	if not label_path.is_empty():
		var label_scene = load(label_path)
		label_instance = label_scene.instantiate()
	else:
		label_instance = default_label.instantiate()
	
	label_instance.text = text
	label_instance.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if not equipped_panel.visible:
		container_current.add_child(label_instance)
	else:
		container_equipped.add_child(label_instance)

func add_spacer() -> void:
	var spacer = Control.new()
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	spacer.custom_minimum_size = Vector2(0, 4)
	if not equipped_panel.visible:
		container_current.add_child(spacer)
	else:
		container_equipped.add_child(spacer)
