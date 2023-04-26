extends Node

## Dependencies: CharacterBody3D, StatusSystem. 
## 
## Optional: Ez Sfx and Music.


@export var on := true
@export var player: CharacterBody3D
@export var status_system: StatusSystem
@export var damage_velocity := 20
@export var base_damage := 1
@export_category("ProportionalDamage")
@export var do_proportional_damage := true
## 1 damage is added to base_damage for every proportional_damage_ratio units 
## of speed over damage_velocity on inpact.
@export var proportional_damage_ratio := 4.0
@export_category("Sound")
@export var do_sfx := false
@export var sfx_player: Node
@export var hit_sfx_name: String
@export var do_hard_hit_sfx := false
@export var hard_hit_level := 30
@export var hard_hit_sfx_name: String
@onready var _just_in_air := not player.is_on_floor()
var _player_last_velocity


func _ready():
	if not player:
		print("FallDamage: player is empty; on -> false")
		on = false
	
	if not status_system:
		print("FallDamage: status_system is empty; on -> false")
		on = false
	
	if not on:
		print("FallDamge: on == false; not running")
		on = false
	
	if proportional_damage_ratio <= 0:
		print("FallDamage: proportional_damage_ratio <= 0; do_proportional_damage -> false.")
		do_proportional_damage = false
	
	if do_sfx:
		if not sfx_player:
			print("FallDamage: sfx_player is empty; do_sfx -> false")
			do_sfx = false
		
		if hit_sfx_name == "":
			print('FallDamage: hit_sfx_name == ""; do_sfx -> false')
			do_sfx = false
		
		if do_hard_hit_sfx:
			if hard_hit_sfx_name == "":
				prints(
						'FallDamage: hard_hit_sfx_name == "";',
						"do_hard_hit_sfx -> false"
				)
				
				do_hard_hit_sfx = false
			
			if hard_hit_level <= damage_velocity:
				prints(
						"FallDamage: hard_hit_level <= damage_velocity;",
						"do_hard_hit_sfx -> false"
				)
				
				do_hard_hit_sfx = false


func _physics_process(delta):
	if on:
		if not player.is_on_floor():
			_player_last_velocity = abs(player.velocity.y)
		
		if _just_in_air != not player.is_on_floor():
			if _just_in_air == true:
				if _player_last_velocity > damage_velocity:
					var _damage = base_damage
					
					if do_proportional_damage:
						var _velocity_surplus = (
								_player_last_velocity - damage_velocity
						)
						
						_damage += floor(
								_velocity_surplus / proportional_damage_ratio
						)
					
					if do_sfx:
						if _player_last_velocity >= hard_hit_level:
							sfx_player.play(hard_hit_sfx_name)
						else:
							sfx_player.play(hit_sfx_name)
					
					status_system.add_status_current("health", -_damage)
				
				_player_last_velocity = 0
			
			_just_in_air = not player.is_on_floor()
