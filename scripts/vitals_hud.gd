extends Control

var lab: Node2D
var label: Label

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	position = Vector2(855,86)
	label = Label.new()
	label.add_theme_font_size_override("font_size",14)
	label.add_theme_color_override("font_color",Color("f2d9a4"))
	var panel := StyleBoxFlat.new()
	panel.bg_color = Color("142b30",0.9)
	panel.border_color = Color("9d824c")
	panel.border_width_bottom = 1
	panel.content_margin_left = 12
	panel.content_margin_right = 12
	panel.content_margin_top = 7
	panel.content_margin_bottom = 7
	panel.set_corner_radius_all(3)
	label.add_theme_stylebox_override("normal",panel)
	add_child(label)

func _process(_delta: float) -> void:
	if lab.combat:
		label.text = "HEALTH %d/3   SCRAP %02d/%d" % [lab.player.health,lab.combat.scrap_count,lab.combat.scrap_positions.size()]
