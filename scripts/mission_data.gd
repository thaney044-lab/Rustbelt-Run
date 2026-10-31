extends RefCounted
## Authored landing geometry. Motion is applied around each listed center.
static func get_level(id: int) -> Dictionary:
	var data := authored_level(id)
	# Later routes demand more precise landings, while banks remain safe staging areas.
	for spec in data.platforms:
		if spec[3] == 20:
			spec[2] -= 12 if id == 1 else 20
			if spec.size() > 4:
				spec[6] *= 1.15 if id < 3 else 1.25
	# Preserve the run-up and landing on the summit's steep final ascent.
	if id == 2:
		data.platforms[19][2] = 160
		data.platforms[20][2] = 160
	data["patrol_speed"] = 76.0 + id * 12.0
	data["active_duration"] = 1.5 + id * 0.2
	return data

static func authored_level(id: int) -> Dictionary:
	if id == 3:
		return {
			"title": "Stormglass Viaduct", "subtitle": "Ground the storm. Reopen the ridge crossing.",
			"control": "grounding relay", "online": "RIDGE GROUNDED", "exit_name": "ridge shelter", "ending": "The ridge is grounded.",
			"period": 4.6, "phase_offset": 2.4,
			"end": 6800, "goal": 6660, "relays": [Vector2(380,490),Vector2(3310,450),Vector2(5720,450)],
			"checks": [3,8,13,18], "bots": [5,10,16], "hazards": [6,11,14,19],
			"platforms": [[240,560,480,80],[610,500,140,20,"xy",45,0.9],[850,440,150,20],[1120,520,320,80],[1470,470,160,20,"xy",55,1.1],[1790,540,320,80],[2140,480,160,20],[2380,420,160,20],[2660,500,320,80],[3000,450,160,20,"x",60,1.1],[3310,520,320,80],[3650,460,160,20],[3900,400,160,20,"y",30,1.0],[4190,500,320,80],[4530,440,160,20],[4780,380,160,20],[5070,480,320,80],[5410,420,160,20,"xy",50,1.0],[5720,520,320,80],[6050,460,160,20],[6290,400,160,20],[6610,500,380,80]]
		}
	if id == 4:
		return {
			"title": "Nightfall Dispatch", "subtitle": "Restore the signals. Bring the night line home.",
			"control": "signal", "online": "SIGNAL ONLINE", "exit_name": "dispatch station", "ending": "The night line is open.",
			"period": 4.8, "phase_offset": 1.9,
			"end": 8000, "goal": 7870, "relays": [Vector2(1090,430),Vector2(3240,440),Vector2(5650,400)],
			"checks": [3,8,13,18,20], "bots": [5,10,15,23], "hazards": [6,11,12,16,21,22],
			"platforms": [[240,560,480,80],[620,550,160,20],[850,510,160,20],[1090,500,320,80],[1430,450,160,20,"x",60,1.1],[1740,530,320,80],[2080,470,160,20],[2320,410,160,20],[2600,490,320,80],[2940,430,160,20,"y",30,1.0],[3240,510,320,80],[3590,450,160,20],[3830,390,160,20],[4110,470,320,80],[4460,410,160,20,"xy",55,1.0],[4770,490,320,80],[5120,430,160,20],[5360,370,160,20],[5650,470,320,80],[6000,410,160,20,"x",65,1.2],[6300,490,320,80],[6640,430,160,20],[6880,370,160,20],[7170,470,320,80],[7500,420,160,20,"y",25,1.0],[7830,520,340,80]]
		}
	if id == 1:
		return {
			"title": "Mosswater Relay", "subtitle": "Wake the pumps beneath the flooded viaduct.",
			"end": 6100, "goal": 5910, "relays": [Vector2(1080,450),Vector2(3180,450),Vector2(5310,450)],
			"checks": [3,8,12,17], "bots": [5,10,15], "hazards": [6,9,13,18],
			"platforms": [[240,560,480,80],[600,500,120,20],[820,440,140,20],[1080,520,260,80],[1400,470,140,20,"x",70,1.1],[1720,540,300,80],[2070,480,150,20],[2300,420,150,20],[2560,500,280,80],[2880,450,150,20],[3180,520,300,80],[3510,470,150,20,"x",60,1.15],[3820,540,300,80],[4150,480,150,20],[4380,420,150,20,"y",30,1.0],[4650,500,300,80],[5000,450,160,20,"x",55,1.1],[5310,520,300,80],[5600,470,140,20],[5910,540,380,80]]
		}
	return {
		"title": "Emberline Summit", "subtitle": "Restore two breakers. Light the summit beacon.",
		"end": 7100, "goal": 6920, "relays": [Vector2(1100,430),Vector2(4100,370)],
		"checks": [3,8,13,18], "bots": [6,11,16,21], "hazards": [4,9,14,19],
		"platforms": [[240,560,480,80],[610,500,140,20],[840,440,140,20],[1100,500,300,80],[1440,450,140,20],[1660,390,140,20],[1940,470,300,80],[2280,420,160,20,"x",60,1.2],[2600,470,300,80],[2950,420,160,20],[3180,360,160,20],[3460,440,300,80],[3800,360,160,20,"y",30,1.1],[4100,440,300,80],[4440,390,160,20],[4680,330,160,20],[4960,380,300,80],[5310,330,160,20,"x",65,1.25],[5630,410,300,80],[5980,360,160,20],[6220,270,160,20],[6510,350,300,80],[6880,410,400,80]]
	}
