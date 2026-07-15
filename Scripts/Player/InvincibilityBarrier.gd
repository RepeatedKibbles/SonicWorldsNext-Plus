class_name InvincibilityBarrier
extends Node2D


const STAR_FRAME_ARR: Array[Array] = [
	[7, 4, 6, 4, 4, 6, 4, 7, 4, 6, 6, 4],
	[2, 3, 4, 5, 6, 7, 6, 5, 4, 3],
	[1, 2, 3, 4, 5, 6, 7, 6, 5, 4, 3, 2],
	[0, 1, 2, 3, 4, 5, 6, 5, 4, 3, 2, 1],
]
const STAR_ANGLE_OFFSETS : Array[float] = [180, 0, 298, 118, 180, 0, 262, 82]
const STAR_ROTATION_RADIUS: int = 16
const POSITION_QUEUE_LENGTH: int = 8

var player: PlayerChar
var player_position_queue: Array[Vector2]
var memory_position: int

var star_trail_offset: Array[Vector2]
var star_rotation: Array[float]
var star_frame: Array[int]

var stars: Array[Sprite2D]


static func create_invincibility_stars(player_owner: PlayerChar) -> void:
	var invincibility_barrier: InvincibilityBarrier = \
			preload("res://Entities/Misc/InvincibilityBarrier.tscn").instantiate()
	player_owner.add_child(invincibility_barrier)
	invincibility_barrier.player = player_owner
	invincibility_barrier.player_position_queue.resize(POSITION_QUEUE_LENGTH)
	invincibility_barrier.star_trail_offset.resize(4)
	invincibility_barrier.star_rotation.resize(2)
	invincibility_barrier.star_frame.resize(2)
	invincibility_barrier.star_rotation[0] = 180
	invincibility_barrier.star_rotation[1] = 0
	for star: Sprite2D in invincibility_barrier.get_children():
		invincibility_barrier.stars.append(star)


func _physics_process(delta: float) -> void:
	global_rotation = 0
	star_frame[0] = (star_frame[0] + 1) % 12
	star_frame[1] = (star_frame[1] + 1) % 10
	
	player_position_queue[memory_position] = player.centerReference.global_position
	
	memory_position = (memory_position + 1) % POSITION_QUEUE_LENGTH
	
	star_trail_offset[0] = player.centerReference.global_position
	for i: int in range(1, star_trail_offset.size()):
		star_trail_offset[i] = player_position_queue[(memory_position - i * 2) % POSITION_QUEUE_LENGTH]
	
	star_rotation[0] = fmod(star_rotation[0] + 144 * player.direction * delta * 60, 360) 
	star_rotation[1] = fmod(star_rotation[1] + 16 * player.direction * delta * 60, 360)
	
	for star: Sprite2D in stars:
		var star_index = stars.find(star)
		var star_pair_num = floori(star_index / 2)
		var frame_arr_size = STAR_FRAME_ARR[star_pair_num].size()
		var angle = deg_to_rad(star_rotation[int(star_index >= 2)] + STAR_ANGLE_OFFSETS[star_index])
		var draw_pos = Vector2(cos(angle), sin(angle)) * STAR_ROTATION_RADIUS
		star.global_position = draw_pos + star_trail_offset[star_pair_num]
		star.frame = STAR_FRAME_ARR[star_pair_num][(star_frame[int(star_pair_num == 1)] + frame_arr_size * int(star_index % 2 == 0 and star_index > 0) / 2) % frame_arr_size]
	
	if player.supTime <= 0 or player.isSuper:
		queue_free()
