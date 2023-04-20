extends Node

#
# 
# Todo: Clean up MarchingCube code. 
#       (Load time at start of clean up: 0.85268998146057. RD = 4, SD = 4)
#       
#       Todo: Break up code into parts; one part per purpuse.
#
#
# Que: For some reason the game is running way slower than before. Find ways to 
#      optimise!
# 
# 
# Hack: Have chunks generate collision shapes.
#       
#       Todo: Chunk generate collision shapes returns "!static_body" is true?
#       
#       Done: Fix bug where doesn't find all the chunks it should in _chunks.
#             
#             Awnser: Typo in the _x, _y, _z variables; wrote _x, _y, _x...
#
#
# Done: Add load time mesurement.
# 
# Done: Check if mobing the marching cube script from a child node of the 
#       meshinstance, to the meshinstance improves preformance. 
#       
#       Awnser: I don't think so.
#
# Done: Change chunks generated indication form chunks / all chunks to %.

# Done: Fix bug where generator chunks aren't added to dictionary, and 
#       generates more chunks than it should.
#       
#       Done: Figure out what causes the bug. 
#
#       Awnser: There wasn't a  problem with the 
#       dictionary; i just didn't wait enough and my tracker for how much 
#       terrain had been loaded was wrong by a bunch:P
#
# Done: Fix bug where generate slice render distance function is behind by one.
# Done: Make generate slice function work with directions


# Ocluding, culling
