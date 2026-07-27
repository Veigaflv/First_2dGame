extends CharacterBody2D

const SPEED = 300.0

var last_direction: Vector2 = Vector2.RIGHT
var is_atacking: bool = false
var hitbox_offset: Vector2

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var punch_sound: AudioStreamPlayer2D = $PunchSound
@onready var hit_box: Area2D = $HitBox


func _ready() -> void:
	#Initialize hitbox_offset
	hitbox_offset = hit_box.position


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("atack") and not is_atacking:
		atack()
		
	# Skip movement if player is atacking
	if is_atacking:
		velocity = Vector2.ZERO
		return
	
	process_movement()
	process_animation()
	move_and_slide()


# -------------------------------------------------------------------
# MOVEMENT AND ANIMATION
# -------------------------------------------------------------------
func process_movement() -> void:
	var direction := Input.get_vector("left", "right", "up", "down")
	if direction != Vector2.ZERO:
		velocity = direction * SPEED
		last_direction = direction
		update_hitbox_offset()
	else:
		velocity = Vector2.ZERO


func process_animation() -> void:
	if is_atacking:
		return
	if velocity != Vector2.ZERO:
		play_animation("run", last_direction)
	else:
		play_animation("idle", last_direction)


func play_animation(prefix: String, dir: Vector2) -> void:
	animated_sprite_2d.flip_h = false;
	
	if dir.x > -1 && dir.x < -0.5 && dir.y > -1 && dir.y < -0.5:
		animated_sprite_2d.play(prefix + "_up_left")
	elif dir.x > 0.5 && dir.x < 1 && dir.y > -1 && dir.y < -0.5:
		animated_sprite_2d.play(prefix + "_up_right")
	elif dir.x > 0.5 && dir.x < 1 && dir.y > 0.5 && dir.y < 1:
		animated_sprite_2d.play(prefix + "_down_right")
	elif dir.x > -1 && dir.x < -0.5 && dir.y > 0.5 && dir.y < 1:
		animated_sprite_2d.play(prefix + "_down_left")
	elif dir.x != 0:
		animated_sprite_2d.flip_h = dir.x < 0
		animated_sprite_2d.play(prefix + "_right")
	elif dir.y < 0:
		animated_sprite_2d.play(prefix + "_up")
	elif dir.y > 0:
		animated_sprite_2d.play(prefix + "_down")


# -------------------------------------------------------------------
# ATACKING
# -------------------------------------------------------------------
func atack() -> void:
	is_atacking = true
	punch_sound.play()
	play_animation("jab", last_direction)


func _on_animated_sprite_2d_animation_finished() -> void:
	if is_atacking:
		is_atacking = false


# -------------------------------------------------------------------
# HITBOX
# -------------------------------------------------------------------
func update_hitbox_offset() -> void:
	var x := hitbox_offset.x
	var y := hitbox_offset.y
	
	match last_direction:
		# UP_LEFT
		var dir when dir.x > -1 && dir.x < -0.5 && dir.y > -1 && dir.y < -0.5:
			hit_box.position = Vector2(-x+9, y-2)
		#UP_RIGHT
		var dir when dir.x > 0.5 && dir.x < 1 && dir.y > -1 && dir.y < -0.5:
			hit_box.position = Vector2(x-4, y-3)
		#DOWN_RIGHT
		var dir when dir.x > 0.5 && dir.x < 1 && dir.y > 0.5 && dir.y < 1:
			hit_box.position = Vector2(-y+9, x-10)
		#DOWN_LEFT
		var dir when dir.x > -1 && dir.x < -0.5 && dir.y > 0.5 && dir.y < 1:
			hit_box.position = Vector2(-y-4, x-8)
		Vector2.LEFT:
			hit_box.position = Vector2(-x+5, y)
		Vector2.RIGHT:
			hit_box.position = Vector2(x, y)
		Vector2.UP:
			hit_box.position = Vector2(y, -x+5)
		Vector2.DOWN:
			hit_box.position = Vector2(-y+5, x-5)
