class_name ItemTooltip
extends Control
## Displays a tooltip for an item when hovered over.
##
## Shows item name, description, stats, etc.

@export var container: Control
@export var margin_container: MarginContainer
@export var max_width: int = 300
@export var default_label: PackedScene = preload("res://scripts/tooltip/sections/labels/DefaultTooltipLabel.tscn")

var sections: Array[TooltipSection] = [
	NameSection.new(),
	SlotSection.new(),
	StatsSection.new(),
	AffixesSection.new(),
	DescriptionSection.new(),
]

func inspect(item: Item) -> void:
	visible = true

	for child in container.get_children():
		child.free()

	for section in sections:
		if section.applies_to(item):
			section.append(item, self)

	if margin_container:
		size.y = margin_container.get_theme_constant("margin_top") + margin_container.get_theme_constant("margin_bottom")

	display()

func display():
	adjust_size()

	var mouse_pos = get_viewport().get_mouse_position()
	var new_pos = mouse_pos + Vector2(16, 16)
	var screen_size = get_viewport_rect().size
	if new_pos.x + size.x > screen_size.x:
		new_pos.x = mouse_pos.x - size.x - 16
	if new_pos.y + size.y > screen_size.y:
		new_pos.y = mouse_pos.y - size.y - 16
	
	global_position = new_pos

func adjust_size():
	var target_width = 0
	var target_height = 0

	if margin_container:
		target_height += margin_container.get_theme_constant("margin_top") + margin_container.get_theme_constant("margin_bottom")

	for child in container.get_children():
		if child is RichTextLabel:
			var font = child.get_theme_font("normal_font")
			var text = child.get_parsed_text()
			var text_size = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, child.get_theme_font_size("normal_font_size"))
			target_width = max(target_width, text_size.x)
			target_height += text_size.y
		else:
			target_height += child.size.y

	target_width = min(target_width, max_width)

	if margin_container:
		target_width += margin_container.get_theme_constant("margin_left") + margin_container.get_theme_constant("margin_right")

	size.x = target_width
	size.y = target_height

func add_line(text: String, label_path: String = "") -> void:
	if not label_path.is_empty():
		var label_scene = load(label_path)
		var label_instance = label_scene.instantiate()
		label_instance.text = text
		container.add_child(label_instance)
	else:
		var label_instance = default_label.instantiate()
		label_instance.text = text
		container.add_child(label_instance)

func add_spacer() -> void:
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 4)
	container.add_child(spacer)
