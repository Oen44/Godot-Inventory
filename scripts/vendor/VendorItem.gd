class_name VendorItem
extends Resource

@export var item_base: ItemBase
@export var quantity: int = 1
@export var roll_affixes: bool = false

@export_group("Price")
@export var gold_price: int = 0 ## Base price, can be increased by rolled affixes
@export var custom_item: ItemBase ## If set, this item will be used as currency instead of gold
