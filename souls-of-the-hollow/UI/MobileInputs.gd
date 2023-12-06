class_name MobileInputs
extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	if OS.has_feature("mobile"):
		visible = true
