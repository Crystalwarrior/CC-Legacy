extends Node

enum { SOUTH, SOUTHEAST, EAST, NORTHEAST, NORTH, NORTHWEST, WEST, SOUTHWEST }

func dirToStr(Dir):
	match Dir:
		SOUTH:
			return "south"
		SOUTHEAST:
			return "southeast"
		EAST:
			return "east"
		NORTHEAST:
			return "northeast"
		NORTH:
			return "north"
		NORTHWEST:
			return "northwest"
		WEST:
			return "west"
		SOUTHWEST:
			return "southwest"
		_:
			return null

func strToDir(Str):
	Str = Str.to_lower()
	match Str:
		"south":
			return SOUTH
		"southeast":
			return SOUTHEAST
		"east":
			return EAST
		"northeast":
			return NORTHEAST
		"north":
			return NORTH
		"northwest":
			return NORTHWEST
		"west":
			return WEST
		"southwest":
			return SOUTHWEST
		_:
			return null

func dirToInitial(Dir):
	match Dir:
		SOUTH:
			return "s"
		SOUTHEAST:
			return "se"
		EAST:
			return "e"
		NORTHEAST:
			return "ne"
		NORTH:
			return "n"
		NORTHWEST:
			return "nw"
		WEST:
			return "w"
		SOUTHWEST:
			return "sw"
		_:
			return null

func initialToDir(Str):
	Str = Str.to_lower()
	match Str:
		"sh":
			return SOUTH
		"se":
			return SOUTHEAST
		"e":
			return EAST
		"ne":
			return NORTHEAST
		"n":
			return NORTH
		"nw":
			return NORTHWEST
		"w":
			return WEST
		"sw":
			return SOUTHWEST
		_:
			return null

func dirToVector(Dir):
	match Dir:
		SOUTH:
			return Vector2(0, 1)
		SOUTHEAST:
			return Vector2(1, 1)
		EAST:
			return Vector2(1, 0)
		NORTHEAST:
			return Vector2(1, -1)
		NORTH:
			return Vector2(0, -1)
		NORTHWEST:
			return Vector2(-1, -1)
		WEST:
			return Vector2(-1, 0)
		SOUTHWEST:
			return Vector2(-1, 1)
		_:
			return Vector2(0, 0)

func vectorToDir(Vec):
#	Vec = Vec.normalized()
#	Vec = Vec.round()
#	print(Vec)
	match Vec:
		Vector2(0, 1):
			return SOUTH
		Vector2(1, 1):
			return SOUTHEAST
		Vector2(1, 0):
			return EAST
		Vector2(1, -1):
			return NORTHEAST
		Vector2(0, -1):
			return NORTH
		Vector2(-1, -1):
			return NORTHWEST
		Vector2(-1, 0):
			return WEST
		Vector2(-1, 1):
			return SOUTHWEST
		_:
			return null