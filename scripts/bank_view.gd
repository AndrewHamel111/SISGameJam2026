class_name BankView
extends Control

const LOSE_CONDITION := -50.0
const WIN_CONDITION := 500.0

@onready var label_2: Label = $Label2
@onready var label_3: Label = $Label3
@onready var color_rect_defecit: ColorRect = $ColorRectDefecit
@onready var color_rect_profit: ColorRect = $ColorRectProfit

func set_money(money: float) -> void:
	var negative : String = "-" if money < 0 else ""
	label_2.text = "%s$%.2f" % [negative, money]
	if money >= 0:
		color_rect_defecit.hide()
		color_rect_profit.show()
		color_rect_profit.set_indexed("size:x", lerpf(2, 69, money / WIN_CONDITION))
	if money < 0:
		color_rect_profit.hide()
		color_rect_defecit.show()
		color_rect_defecit.set_indexed("position:x", lerpf(20, 6, money / LOSE_CONDITION))
		color_rect_defecit.set_indexed("size:x", lerpf(2, 15, money / LOSE_CONDITION))
	
	label_3.text = "$%.2f left to\nfinancial freedom!" % [WIN_CONDITION - money]
