# Scene Hierarchy

```
Main
└── World
    └── Player
```

The Editor only shows one `Node` (the root node) in the Scene,
with a script attached to it. Why doesn't `Main` show it's
children?

This Scene Hierarchy is not visible from within the Godot Editor
because I `add_child` nodes in script, not in the Godot Editor.

## Node Hierarchy

Here is the node hierarchy when the game has a single player:

```
root
└── Main
    └── World
        └── Player
            ├── Tween
            ├── RayCast2D
            ├── HitBox
            └── Block
```

### What is this `root` node?

Godot makes the top-level `root` parent node, this is not
something I do.

`root` is useful for determining where execution started. I
determine which `Scene` execution started in by checking if the
node's **parent** matches `root`.

For example,

- I open the `Player` scene in the Godot Editor and press `F6`
    - execution begins in `Player.tscn`
    - and in `Player.gd`, `get_parent().name` returns `"root"`

- But if I press `F5` instead
    - execution begins in `Main.tscn`
    - and in `Player.gd`, `get_parent().name` returns `"World"`
    - (in `Main.gd`, `get_parent().name` returns `"root"`)

# Hierarchy

I don't use the Godot Editor to add child nodes. I do this in
code instead.

For example, in the Editor I assign script `Main.gd` to scene
`Main.tscn`. In `Main.gd`, I create an instance of the `World`
scene and add it as a child node to node `Main`.

See the docs for [creating nodes](https://docs.godotengine.org/en/stable/getting_started/step_by_step/scripting_continued.html?highlight=_ready#creating-nodes).

## Add a **node** class instance as a **child node**

There are two steps to add an instance of a *class* as a *child
node* in a script:

1. Instantiate the class with `new()`. Define a property (a
   "global" variable in this script) assigned to this instance.

   *The instance is now a property of the class defined by
   this script. But the instance is not yet a child node of the
   Scene, the root node of which has this script assigned to
   it.*

2. Add the instance as a child node by calling `add_child()` in
   `_ready()`.

To use `new()`, the class must have a name. The built-in classes
have names, like `Tween`, and `RayCast2D`.

For classes I define in `.gd` scripts, the GDScript Compiler knows about the
class because the script's first line, `class_name = Blah`,
registers Blah with the `_global_script_classes`. See top-level
file `project.godot` for the `_global_script_classes`.

## Add a **scene** class instance as a **child node**

There are three steps to instantiate a scene as a child node.

1. Load or preload the scene:

```gdscript
const player_scene = preload("res://scenes/Player.tscn")
```

2. Instantiate with `instance()` (instead of `new()`):

```gdscript
    var player1 = player_scene.instance()
```

3. Add the instance as a child node by calling `add_child()` in
   `_ready()`:

```gdscript
    add_child(player1)
```

For example, `Player.gd` does not have a `class_name = Player`
line because I already have scene `Player.tscn`. I assign the
`Player.gd` script to scene `Player.tscn` in the Godot Editor.

The Parent makes Player a Child node in code.

See the docs for [instancing
scenes](https://docs.godotengine.org/en/stable/getting_started/step_by_step/scripting_continued.html?highlight=_ready#instancing-scenes).

## Why not make `Player` a script-defined class like `HitBox`

Two reasons:

1. Scenes have execution benefits under the hood.
2. As a scene, it is a stand-alone game component I can test with
   `F6`.


