extends Node
## Small local save; levels remain available for direct play.
const PATHS := ["res://scenes/movement_lab.tscn", "res://scenes/mosswater.tscn", "res://scenes/emberline.tscn", "res://scenes/stormglass.tscn", "res://scenes/nightfall.tscn"]
const TITLES := ["First Shift", "Mosswater Relay", "Emberline Summit", "Stormglass Viaduct", "Nightfall Dispatch"]
const SAVE_PATH := "user://campaign.cfg"
var records: Dictionary = {}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) == OK:
		for id in PATHS.size():
			var record = config.get_value("levels",str(id),{})
			if record is Dictionary and typeof(record.get("time")) in [TYPE_INT,TYPE_FLOAT] and typeof(record.get("scrap")) == TYPE_INT:
				records[id] = record

func play(id: int) -> void:
	if id < 0 or id >= PATHS.size(): return
	get_tree().paused = false
	get_tree().change_scene_to_file(PATHS[id])

func menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/campaign_menu.tscn")

func record_completion(id: int, seconds: float, scrap: int) -> void:
	var old: Dictionary = records.get(id,{})
	records[id] = {"time": minf(seconds,float(old.get("time",seconds))), "scrap": maxi(scrap,int(old.get("scrap",0)))}
	var config := ConfigFile.new()
	for key in records: config.set_value("levels",str(key),records[key])
	if config.save(SAVE_PATH) != OK:
		push_warning("Campaign record could not be saved on this device.")
