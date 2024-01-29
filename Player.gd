extends RigidBody3D

# Global variables

## How much vertical force to apply when moving.
@export_range(750.0, 3000.0) var thrust: float = 1000.0

@export var torque_thrust: float = 100.0

var is_transitioning: bool = false

@onready var explosion_audio: AudioStreamPlayer = $ExplosionAudio
@onready var level_complete_audio_: AudioStreamPlayer = $LevelCompleteAudio
@onready var rocket_audio: AudioStreamPlayer3D = $RocketAudio

@onready var booster_particles: GPUParticles3D = $BoosterParticles
@onready var booster_particles_right: GPUParticles3D = $BoosterParticlesRight
@onready var booster_particles_left: GPUParticles3D = $BoosterParticlesLeft
@onready var explosion_particles: GPUParticles3D = $ExplosionParticles
@onready var success_particles: GPUParticles3D = $SuccessParticles


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Quitting the game with esc
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()
	# If space pressed do every frame
	if Input.is_action_pressed("boost"):
		# Moving player up
		apply_central_force(basis.y * delta * thrust)
		# Emit particles
		booster_particles.emitting = true
		# Play audio
		if rocket_audio.playing == false:
			rocket_audio.play()
	else:
		rocket_audio.stop()
		booster_particles.emitting = false
		
	# If left_arrow pressed do every frame
	if Input.is_action_pressed("rotate_left"):
		apply_torque(Vector3(0.0, 0.0, torque_thrust * delta))
		booster_particles_right.emitting = true
	else:
		booster_particles_right.emitting = false
		
	# If right_arrow pressed do every frame
	if Input.is_action_pressed("rotate_right"):
		apply_torque(Vector3(0.0, 0.0, -torque_thrust * delta))
		booster_particles_left.emitting = true
	else:
		booster_particles_left.emitting = false

func _on_body_entered(body: Node) -> void:
	if is_transitioning == false:
	
		if "Goal" in body.get_groups():
			complete_level(body.file_path)
		
		if "Hazard" in body.get_groups():
			crash_sequence()

func crash_sequence() -> void:
	print("KABOOM!")
	set_process(false)
	
	explosion_particles.emitting = true
	explosion_audio.play()
	rocket_audio.stop()
	
	is_transitioning = true
	
	var tween = create_tween()
	tween.tween_interval(2.5)
	tween.tween_callback(get_tree().reload_current_scene)

func complete_level(next_level_file: String) -> void:
	print("Level Complete")
	set_process(false)
	
	success_particles.emitting = true
	level_complete_audio_.play()
	rocket_audio.stop()
	
	is_transitioning = true
	
	var tween = create_tween()
	tween.tween_interval(2.5)
	tween.tween_callback(get_tree().change_scene_to_file.bind(next_level_file))
