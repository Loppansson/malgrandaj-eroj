extends Node

## Dependencies: CharacterBody3D, StatusSystem. 
## 
## Optional: Ez Sfx and Music.


@export var on := true
@export var player: CharacterBody3D
@export var status_system: StatusSystem
@export var damage_velocity := 30
@export var base_damage := 1
@export_category("ProportionalDamage")
@export var proportional_damage := false
## 1 damage is added to base_damage for every proportional_damage_ratio units 
## of speed over damage_velocity on inpact.
@export var proportional_damage_ratio := 5.0
@export var sfx_player: Node
@onready var _just_in_air := not player.is_on_floor()
var _player_last_velocity
var _force_stop := false


func _ready():
	if not on:
		print("FallDamge: on = false; not running")
	
	if not player:
		print("FallDamage: player is empty; not running")
		_force_stop = true
	
	if not status_system:
		print("FallDamage: status_system is empty; not running")
		_force_stop = true
	
	if proportional_damage_ratio <= 0:
		print("FallDamage: proportional_damage_ratio <= 0; proportional_damage -> false.")
		proportional_damage = false


func _physics_process(delta):
	if not _force_stop and on:
		if not player.is_on_floor():
			_player_last_velocity = abs(player.velocity.y)
		
		if _just_in_air != not player.is_on_floor():
			if _just_in_air == true:
				if _player_last_velocity > damage_velocity:
					var _damage = base_damage
					
					if proportional_damage:
						var _velocity_surplus = (
								_player_last_velocity - damage_velocity
						)
						
						_damage += floor(
								_velocity_surplus / proportional_damage_ratio
						)
					
					
					status_system.add_status_current("health", -_damage)
				
				_player_last_velocity = 0
			
			_just_in_air = not player.is_on_floor()
