extends Node2D
## A script for the invincibility barrier that controls stars that spin around the player's position

## An array of arrays that store the frames to cycle through
var STAR_FRAME_ARR: Array[PackedByteArray] = [
	PackedByteArray([7, 4, 6, 4, 4, 6, 4, 7, 4, 6, 6, 4]),
	PackedByteArray([2, 3, 4, 5, 6, 7, 6, 5, 4, 3]),
	PackedByteArray([1, 2, 3, 4, 5, 6, 7, 6, 5, 4, 3, 2]),
	PackedByteArray([0, 1, 2, 3, 4, 5, 6, 5, 4, 3, 2, 1]),
]
## An array of values used to offset the stars for each pair
const STAR_ANGLE_OFFSETS: Array[float] = [0, 118.125, 0, 81.5625]
## The radius of rotation around the player
const STAR_ROTATION_RADIUS: int = 11
## The length of the circular queue used to store the player's position
const POSITION_QUEUE_LENGTH: int = 12

## The player that owns this barrier
@onready var player: PlayerChar = get_parent()
## A circular queue that stores the player's position
var player_position_queue: PackedVector2Array
## The index of the current position in the queue
var memory_index: int

## An array that stores the positions of star pairs
var star_position_arr: PackedVector2Array
## An array that stores angles used to rotate the stars
## The size of the array determines how many variations of angles that can be stored
var star_angle: Array[float]
## An array that stores frame indices used to animate the stars
## The size of the array determines how many variations of frames that can be stored
var star_frame: Array[int]

## An array of Sprite2Ds representing stars to iterate over
var stars: Array[Sprite2D]


# Initialize the barrier
func _ready() -> void:
	# Resize some arrays
	player_position_queue.resize(POSITION_QUEUE_LENGTH)
	star_position_arr.resize(4)
	star_angle.resize(2)
	star_frame.resize(2)
	# Append the child nodes that represent the stars of this barrier instance to the stars array
	for star: Sprite2D in get_children():
		stars.append(star)


func _physics_process(delta: float) -> void:
	# Bug: The player's PhysicsObject is rotated based on the current collision mode, for example,
	# if the player goes from a slope to the left or right wall, the player will be rotated,
	# and since the barrier is a child of the player, the barrier will rotate along with them,
	# so either we parent the barrier to smth else in the static function, like the level, for example,
	# or set the barrier's global rotation to 0 every frame to prevent rotation, just like here.
	# The problem with the second method, tho, is that when the player jumps from a left or right wall,
	# their rotation is reset, which causes the barrier to rotate for a frame before resetting its rotation..
	global_rotation = 0
	
	# Increment the frame indices
	star_frame[0] = (star_frame[0] + 1) % 12
	star_frame[1] = (star_frame[1] + 1) % 10
	
	# Store the player's current center position to the queue
	player_position_queue[memory_index] = player.centerReference.global_position
	
	# Increment the memory index so that the stars read from the new index
	memory_index = (memory_index + 1) % POSITION_QUEUE_LENGTH
	
	# Always set the position of first pair to the player's position
	# Useless fun fact: for whatever reason, when the player obtains invincibility, the trail stars rotate
	# around the origin point of the current scene for some time before instantly going to the player,
	# which can make it look like each pair gradually appears right after getting invincibility
	# (writing the word 'invincibility' everytime gets very annoying..)
	star_position_arr[0] = player.centerReference.global_position
	# Iterate over the array of the star trail positions and set the positions of the star trails
	# to the player's position frames ago and offset them so that the farthest pair from the player
	# is positioned according to the most previous position in the queue
	# (I think the position tracking part needs better descriptions, bruh..)
	for i: int in range(1, star_position_arr.size()):
		var offset_multiplier: int = POSITION_QUEUE_LENGTH / star_position_arr.size()
		star_position_arr[i] = player_position_queue[(memory_index - i * offset_multiplier) % POSITION_QUEUE_LENGTH]
	
	# Increment the angles and rotate based on the player's direction
	star_angle[0] = fmod(star_angle[0] + 101.25 * player.direction * delta * 60, 360) 
	star_angle[1] = fmod(star_angle[1] + 11.25 * player.direction * delta * 60, 360)
	
	# Iterate over the stars to position and animate em
	# Also, there are local variables that are defined here to keep the code nice and clean
	# (cuz nobody likes scrolling horizontally lol..)
	for star: Sprite2D in stars:
		# The index of the star node in the array
		var star_index: int = stars.find(star)
		# The current pair number
		var star_pair_num: int = floori(star_index / 2)
		# Is the index number even or not?
		var is_index_even: bool = star_index % 2 == 0
		# The array that's used to animate the current pair
		var frame_arr: PackedByteArray = STAR_FRAME_ARR[star_pair_num]
		# The index that points to a variation of a frame
		var frame_index: int = int(star_pair_num == 1)
		# The increment of the frame
		var frame_increment: int = frame_arr.size() * int(is_index_even and star_index > 0) / 2
		# The index that points to a variation of an angle
		var angle_index: int = int(star_pair_num != 0)
		# The increment of the angle
		var angle_increment: float = 180 * int(is_index_even) + STAR_ANGLE_OFFSETS[star_pair_num]
		# The rotation of the star
		var star_rotation: float = deg_to_rad(star_angle[angle_index] + angle_increment)
		# The position of the star relative from the player
		var star_relative_position: Vector2 = Vector2.ONE.rotated(star_rotation) * STAR_ROTATION_RADIUS
		# Set the star position
		star.global_position = star_relative_position + star_position_arr[star_pair_num]
		# Animate the star
		star.frame = frame_arr[(star_frame[frame_index] + frame_increment) % frame_arr.size()]
