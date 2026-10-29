extends AnimatableBody2D

var origin := Vector2.ZERO
var elapsed := 0.0
var pace := 1.2
var travel := 90.0

func _ready() -> void:
	origin = position

func _physics_process(delta: float) -> void:
	elapsed += delta
	position = origin + Vector2(sin(elapsed * pace) * travel, 0)
