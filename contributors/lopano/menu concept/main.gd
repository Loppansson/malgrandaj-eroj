extends Node

#=----------------------------=#
#             MAIN             #
#=----------------------------=#
# Manages the game state at    #
# the highest level.           #
#                              #
# Changing scene should be     #
# done through this node (ex.  #
# swiching between menues) to  #
# keep things consistent and   #
# more robust.                 #
#=----------------------------=#

## Stores all the scenes in the
## game. These are searched 
## though by name when switching
## scenes.
@export var scenes: Array[PackedScene]













