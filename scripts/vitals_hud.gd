extends Control

var lab: Node2D
var label: Label
var previous_health := 3
var damage_flash := 0.0

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

func _process(delta: float) -> void:
	damage_flash = maxf(0, damage_flash - delta)
	if lab.combat:
		label.text = "HEALTH %d/3   SCRAP %02d/%d" % [lab.player.health,lab.combat.scrap_count,lab.combat.scrap_positions.size()]

		if lab.player.health < previous_health:
			damage_flash = 0.5
		previous_health = lab.player.health
		queue_redraw()

func _draw() -> void:
	if not lab.player:
		return
	var width := maxf(150, label.size.x)
	for i in 3:
		var r := Rect2(i * (width / 3.0), 39, width / 3.0 - 4, 6)
		draw_style_box(segment(Color("132b30")), r.grow(1))
		var color := Color("95c9a0") if i < lab.player.health else Color("4e4e43")
		if damage_flash > 0 and i >= lab.player.health:
			color = color.lerp(Color("e7a278"), damage_flash / 0.5)
		draw_style_box(segment(color), r)

func segment(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(2)
	return style
