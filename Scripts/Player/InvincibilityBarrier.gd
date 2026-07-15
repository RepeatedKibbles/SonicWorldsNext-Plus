class_name InvincibilityBarrier
extends Node2D


const STAR_FRAME_ARR: Array[Array] = [
	[7, 4, 6, 4, 4, 6, 4, 7, 4, 6, 6, 4],
	[2, 3, 4, 5, 6, 7, 6, 5, 4, 3],
	[1, 2, 3, 4, 5, 6, 7, 6, 5, 4, 3, 2],
	[0, 1, 2, 3, 4, 5, 6, 5, 4, 3, 2, 1],
]
const STAR_ANGLE_OFFSETS : Array[float] = [0, 118, 0, 82]
const STAR_ROTATION_RADIUS: int = 16
const POSITION_QUEUE_LENGTH: int = 8

var player: PlayerChar
var player_position_queue: Array[Vector2]
var memory_position: int

var star_position_arr: Array[Vector2]
var star_rotation: Array[float]
var star_frame: Array[int]

var stars: Array[Sprite2D]


static func create_invincibility_stars(player_owner: PlayerChar) -> void:
	var invincibility_barrier: InvincibilityBarrier = \
			preload("res://Entities/Misc/InvincibilityBarrier.tscn").instantiate()
	player_owner.add_child(invincibility_barrier)
	invincibility_barrier.player = player_owner
	invincibility_barrier.player_position_queue.resize(POSITION_QUEUE_LENGTH)
	invincibility_barrier.star_position_arr.resize(4)
	invincibility_barrier.star_rotation.resize(2)
	invincibility_barrier.star_frame.resize(2)
	for star: Sprite2D in invincibility_barrier.get_children():
		invincibility_barrier.stars.append(star)


func _physics_process(delta: float) -> void:
	global_rotation = 0
	star_frame[0] = (star_frame[0] + 1) % 12
	star_frame[1] = (star_frame[1] + 1) % 10
	
	player_position_queue[memory_position] = player.centerReference.global_position
	
	memory_position = (memory_position + 1) % POSITION_QUEUE_LENGTH
	
	star_position_arr[0] = player.centerReference.global_position
	for i: int in range(1, star_position_arr.size()):
		star_position_arr[i] = player_position_queue[(memory_position - i * 2) % POSITION_QUEUE_LENGTH]
	
	star_rotation[0] = fmod(star_rotation[0] + 144 * player.direction * delta * 60, 360) 
	star_rotation[1] = fmod(star_rotation[1] + 16 * player.direction * delta * 60, 360)
	
	for star: Sprite2D in stars:
		var star_index: int = stars.find(star)
		var star_pair_num: int = floori(star_index / 2)
		var is_index_even: bool = star_index % 2 == 0
		var frame_arr: Array = STAR_FRAME_ARR[star_pair_num]
		var frame_index: int = int(star_pair_num == 1)
		var frame_increment: int = frame_arr.size() * int(is_index_even and star_index > 0) / 2
		var angle_index: int = int(star_pair_num != 0)
		var angle_increment: float = 180 * int(is_index_even) + STAR_ANGLE_OFFSETS[star_pair_num]
		var star_angle: float = deg_to_rad(star_rotation[angle_index] + angle_increment)
		var star_relative_position: Vector2 = Vector2(cos(star_angle), sin(star_angle)) * STAR_ROTATION_RADIUS
		star.global_position = star_relative_position + star_position_arr[star_pair_num]
		star.frame = frame_arr[(star_frame[frame_index] + frame_increment) % frame_arr.size()]
	
	if player.supTime <= 0 or player.isSuper:
		queue_free()
