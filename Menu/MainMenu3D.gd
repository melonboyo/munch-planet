extends Node3D


func _ready():
	setup_graphics_detail()
	Settings.changed.connect(setup_graphics_detail)


func setup_graphics_detail():
	var level = Settings.graphics_detail
	$WorldEnvironment.environment.ssao_enabled = level > Constants.Graphics.Low
	$WorldEnvironment.environment.ssil_enabled = level > Constants.Graphics.Medium
	$WorldEnvironment.environment.sdfgi_enabled = level > Constants.Graphics.Low
	$WorldEnvironment.environment.volumetric_fog_enabled = level > Constants.Graphics.Low
