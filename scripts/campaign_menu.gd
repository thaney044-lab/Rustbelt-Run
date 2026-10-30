extends Control
const PANORAMA = preload("res://assets/art/painted/foundry_panorama.png")
var buttons: Array[Button] = []

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var background := TextureRect.new()
	background.texture = PANORAMA
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.modulate = Color(0.48,0.6,0.55)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	var shade := ColorRect.new()
	shade.color = Color("0b211e",0.75)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)
	label("R U S T B E L T   R U N",Vector2(100,64),40,Color("f1dfb6"))
	label("THE VALLEY CAMPAIGN",Vector2(102,122),14,Color("c7ae76"))
	label("Three routes. One mechanic. A valley worth bringing back to life.",Vector2(102,157),18,Color("c2d0be"))
	var subtitles := ["The full original journey · repair works, freight aqueduct and workshop", "Restart three pumps · moving ferries, water jets and a flooded viaduct", "Restore the beacon · high catwalks, moving lifts and timed presses"]
	for id in 3:
		var button := Button.new()
		button.position = Vector2(100,216+id*112)
		button.size = Vector2(952,92)
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		var record: Dictionary = Campaign.records.get(id,{})
		var stamp := "READY TO EXPLORE"
		if not record.is_empty():
			stamp = "COMPLETE · BEST %02d:%02d · MOST SCRAP %d" % [int(record.time)/60,int(record.time)%60,record.scrap]
		button.text = "  %02d   %s     /     %s\n  %s" % [id+1,Campaign.TITLES[id].to_upper(),stamp,subtitles[id]]
		button.add_theme_font_size_override("font_size",17)
		var normal := StyleBoxFlat.new()
		normal.bg_color = Color("1c3734",0.94)
		normal.border_color = Color("71866b")
		normal.set_border_width_all(1)
		normal.set_corner_radius_all(5)
		button.add_theme_stylebox_override("normal",normal)
		var focus := normal.duplicate()
		focus.bg_color = Color("365449")
		focus.border_color = Color("edcf8c")
		focus.set_border_width_all(2)
		button.add_theme_stylebox_override("focus",focus)
		button.add_theme_stylebox_override("hover",focus)
		button.add_theme_color_override("font_color",Color("f0dfbc"))
		button.pressed.connect(Campaign.play.bind(id))
		add_child(button)
		buttons.append(button)
	for id in 3:
		buttons[id].focus_neighbor_top = buttons[id].get_path_to(buttons[(id+2)%3])
		buttons[id].focus_neighbor_bottom = buttons[id].get_path_to(buttons[(id+1)%3])
	buttons[0].grab_focus()
	label("A/D or arrows · Move    Space · Jump    J/K · Wrench    E · Use    Esc / Start · Pause",Vector2(102,579),14,Color("d5c9a5"))
	label("Choose any level · completion records save on this device",Vector2(102,608),12,Color("9bb2a2"))

func label(text: String, at: Vector2, size: int, color: Color) -> void:
	var item := Label.new()
	item.text = text
	item.position = at
	item.add_theme_font_size_override("font_size",size)
	item.add_theme_color_override("font_color",color)
	item.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(item)
