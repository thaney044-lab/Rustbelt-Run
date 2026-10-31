extends "res://scripts/level_director.gd"

func _process(delta: float) -> void:
	if paused: return
	if complete:
		lab.player.invulnerability = 1.0
		return
	time += delta
	elapsed += delta
	if lab.player.spawn_point != last_checkpoint:
		last_checkpoint = lab.player.spawn_point
		lab.effects.celebrate(lab.player.position,Color("9cdbb1"),"CHECKPOINT")
		message("Checkpoint secured · power stays restored after retries")
	toast_time = maxf(0,toast_time-delta)
	toast.visible = toast_time > 0
	toast.modulate.a = minf(1,toast_time)
	var text: String = lab.data.title.to_upper()+"\n"+objective_text(lab.player.position.x)
	if lab.combat.notice_time > 0: text = lab.combat.notice
	if lab.status.text != text:
		lab.status.text = text
		lab.status.reset_size()
	route.text = "%s   /   POWER %d/%d   /   %02d:%02d" % [lab.data.title.to_upper(),lab.relay_count(),lab.relay_on.size(),int(elapsed)/60,int(elapsed)%60]
	progress.points = PackedVector2Array([Vector2(28,623),Vector2(28+clampf(lab.player.position.x/float(lab.data.goal),0,1)*1096,623)])
	# Finish after the physics tick so pickups on the exit bank enter the results.
	if lab.player.position.x > lab.data.goal and lab.player.is_on_floor() and lab.relay_count() == lab.relay_on.size(): finish()

func objective_text(_x: float) -> String:
	for i in lab.relay_on.size():
		if not lab.relay_on[i]:
			var distance: int = int(lab.data.relays[i].x-lab.player.position.x)
			if lab.player.position.distance_to(lab.data.relays[i]) < 65: return "E · Restore this " + (lab.control_name()+".")
			if abs(distance) < 65: return "Land beside the control · E restores power."
			return "Restore %s %d/%d · %s %d m" % [lab.control_name(),i+1,lab.relay_on.size(),"right" if distance > 0 else "left",int(abs(distance)/20)]
	return "All power restored · head right to the " + str(lab.data.get("exit_name","harbour gate" if mission_id == 1 else "summit beacon"))+"."

func finish() -> void:
	if complete: return
	complete = true
	lab.player.controls_enabled = false
	lab.player.velocity = Vector2.ZERO
	heading.text = lab.data.get("ending","The water is moving again." if mission_id == 1 else "The valley has a signal.")
	details.text = "%s COMPLETE\n%02d:%02d · %d/%d scrap · %d retries\n%s" % [lab.data.title.to_upper(),int(elapsed)/60,int(elapsed)%60,lab.combat.scrap_count,lab.combat.scrap_positions.size(),retries,"The next route is ready for you." if mission_id < Campaign.PATHS.size()-1 else "All five routes are ready to revisit from the level selector."]
	primary.text = "NEXT / " + Campaign.TITLES[mission_id+1].to_upper() if mission_id < Campaign.PATHS.size()-1 else "RETURN TO LEVEL SELECT"
	secondary.text = "EXPLORE FROM CHECKPOINT / R"
	overlay.show()
	primary.grab_focus()
	toast.hide()
	if get_tree().current_scene == lab: Campaign.record_completion(mission_id,elapsed,lab.combat.scrap_count)

func _draw() -> void:
	pass
