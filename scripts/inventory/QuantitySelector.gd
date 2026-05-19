class_name QuantitySelector
extends Control

signal confirmed(quantity: int)
signal canceled

@export var item_icon: TextureRect
@export var item_name_label: Label
@export var quantity_label: RichTextLabel
@export var slider: HSlider
@export var confirm_button: Button
@export var cancel_button: Button

var item: Item

func _ready():
	confirm_button.pressed.connect(_on_confirm_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)
	slider.value_changed.connect(_on_slider_value_changed)

func _on_confirm_pressed():
	confirmed.emit(slider.value)
	item = null

func _on_cancel_pressed():
	canceled.emit()
	item = null

func set_item(new_item: Item) -> void:
	item = new_item
	item_icon.texture = item.base.icon
	item_name_label.text = item.base.name
	slider.value = 1
	slider.max_value = item.quantity
	quantity_label.text = "[color=white]1[/color][color=orange]/%d[/color]" % item.quantity

func _on_slider_value_changed(value: float) -> void:
	quantity_label.text = "[color=white]%d[/color][color=orange]/%d[/color]" % [int(value), int(slider.max_value)]
