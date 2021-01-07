# [ ] Double-collisions knock players off the grid

## How collisions work

### Single collision

One player bumps into a player standing still, no problem.

- when a `Player` is about to move to a square occupied by
  another player, `Player` reports to World the name of the
  player they are about to hit and the `collision_normal`
- `World` announces to all players who is hit and which face they
  were hit on

### Double collision

Problem was that when two players are both moving towards each
other, the collision was not detected because both the test for
collisions only happened when the player was about to move -- if
the opponent is not in the other square yet, or if the opponent
just left the other square -- no collision was detected and
they'd pass through each other.

## Handle double collisions with `Area2D`

I "fixed" this by checking `Area2D` for overlap.

I shrink the `Area2D` extents so that it only triggers when
players are overlapping.

If players are both moving and their Area2D overlap:

- `Player` announces to world the direction they are moving and
  the player they are overlapping with
- `World` announces to all players as if this was a regular hit,
  the difference being that now `World` does the announcement
  twice: once for each player in the overlap; also the
  `collision_normal` is determined from the direction the players
  are moving

This did not eliminate the stack overflow caused by the RayCast2D
collision detection when players were directly on top of each
other. This still needs the "temporary fix" that players do not
report collisions when the `collision_normal` is (0,0).

## Double collisions knock players off the grid

The issue now is that players get knocked off the grid when both
are moving and they collide. I think this is because I'm
calculating players new position by just multiplying their
current position with the `collision_normal`. When players are in
motion, their "current position" is not on the grid.

- [ ] player's maintain knowledge of their `grid_position`
    - only update `grid_position` at the end of a tween
    - always use `grid_position` when calculating new position
      after a collision

## Switch to `TileMap`!

Note: this problem will be much simpler when I replace the grid
with a proper `TileMap`.

# [ ] replace `Grid.gd` with a `TileMap`

- I rolled my own grid
    - that was dumb, it's time to switch
    - issues:
        - sometimes players get off grid when playing with
          joysticks
        - my code is not re-usable, e.g., a game with an
          isometric `TileMap`
    - switch to a `TileMap`
- [ ] how do I do a `TileMap` in code?
    - [x] watch the GDQuest tutorial
        - I did the "first-godot-2d-platformer"
        - now I have a `TileMap` I can poke at in `Inspector`
          while looking at the reference documentation in the
          `Script` tab
    - [x] put `TileMap` code snippets in `snippets.md`
    - [ ] watch the KidsCanCode tutorials on `TileMap`

# Make a background

Things to implement in order of difficulty...

- [ ] simple black
- [ ] animated "noise" background
    - black, but random grainy greys, like TV white noise, but
      darker
- [ ] crazy rainbow worm animation
    - background is black with a chaotic celtic knot tiling with
      the "rope" outlined in rainbow colors (a cycling through
      all the colors)
    - the rope is not permanently visible but instead slithers
      around the screen
    - do this by animating which part of the rope is visible
    - so the background is like a compost heap, but in a
      futuristic, infinite void kind of way
    - another way to do this might be calculate curved paths and
      do a combination motion and color tween of two lines along
      the path -- but how do I get worm interwining effects?
