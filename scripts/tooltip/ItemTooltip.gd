extends Control
## Displays a tooltip for an item when hovered over.
##
## Shows item name, description, stats, etc.

@export var container: Control
@export var margin_container: MarginContainer
@export var max_width: int = 300
@export var default_label: PackedScene = preload("res://scripts/tooltip/sections/labels/DefaultTooltipLabel.tscn")

var _show_advanced: bool = false

var sections: Array[TooltipSection] = [
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
	if event is InputEventKey:
		if event.keycode == Key.KEY_ALT:
			if _show_advanced != event.pressed:
				_show_advanced = event.pressed

func inspect(inventory_item: InventoryItem) -> void:
	visible = true

	for child in container.get_children():
		child.free()

	var item = inventory_item.item
	for section in sections:
		if section.applies_to(item):
			section.append(item, self)

	if margin_container:
		size.y = margin_container.get_theme_constant("margin_top") + margin_container.get_theme_constant("margin_bottom")

	display(inventory_item.get_global_rect())

func display(rect: Rect2):
	adjust_size()

	var new_pos = rect.position + Vector2(rect.size.x + 5, 0)
	var screen_size = get_viewport_rect().size
	if new_pos.x + size.x > screen_size.x:
		new_pos.x = rect.position.x - size.x - 5
	if new_pos.y + size.y > screen_size.y:
		new_pos.y = screen_size.y - size.y
	
	global_position = new_pos

## I hate this
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
			if child.text.find("[img") != -1:
				text_size.x += child.get_theme_font_size("normal_font")
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
	var label_instance = null
	
	if not label_path.is_empty():
		var label_scene = load(label_path)
		label_instance = label_scene.instantiate()
	else:
		label_instance = default_label.instantiate()
	
	label_instance.text = text
	label_instance.mouse_filter = Control.MOUSE_FILTER_IGNORE
	container.add_child(label_instance)

func add_spacer() -> void:
	var spacer = Control.new()
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	spacer.custom_minimum_size = Vector2(0, 4)
	container.add_child(spacer)
