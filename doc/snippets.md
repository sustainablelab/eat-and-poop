## `TileMap` snippets

### New TileMap in script

Skip this if the script is attached to a TileMap Node in the
editor. I can't think of a reason why I wouldn't create the
TileMap node in the editor, so I'll probably never need this, but
here it is.

```gdscript NOT TESTED
var tilemap := TileMap.new()

func _ready():
    add_child(tilemap)
```

### Property snippets

A `TileMap` manages all the instances of stuff in the world that
does not require complex interactive behavior (complex like
players and enemies). `TileMap` makes it easy to lay down a grid
of tiles based on a library of tile artwork called the `TileSet`.

Otherwise, I'd have to have to manage each tile as its own node
in the scene tree when laying out maps -- that would be
impossible. And from videos I saw on Kids Can Code, it looks
especially useful for procedurally generated maps.

The tile instances have some interactive behavior. For example,
"wall" tiles that the player collides with, or "trail" tiles if
the player leaves a trail of something behind them (like the Tron
racing game).

#### property `mode`

```gdscript NOT TESTED
# Orthogonal tiles (top-down maze or a side-view platformer)
tilemap.mode = MODE_SQUARE
# Isometric (still 2D)
tilemap.mode = MODE_ISOMETRIC
# Custom? Maybe triangular grids for hexagon games?
tilemap.mode = MODE_CUSTOM
```

#### property `tile_set`

```gdscript NOT TESTED
tilemap.tile_set = "res://assets/tileset.tres"
```

#### property `centered_texture`

Center textures in the middle of the tile.

```gdscript NOT TESTED
tilemap.centered_texture = true # default is false
```


