# rules
- start as one block
- screen has food and poop
    - food is edible
    - food is a colorful block
    - poop is not edible
    - poop is a grey block
- touch a block to eat it
    - wherever the player's group touches the block, it attaches
      there
    - the incentive is to eat carefully to avoid an unweildy
      shape that cannot navigate around the obstacles on the
      screen
    - the obstacles increase as players poop
- stand still too long and player poops
    - a random outer block is pooped
    - define *outer*:
        - a block is an outer block if it touches the bounding
          box around the player
    - a pooped block is poop; poop is not editable
    - the player's group is only the blocks that are still
      *attached*
    - define *attached*:
        - a block is attached if it touches on a side
        - touching on a corner is not a connection
    - therefore, depending on how other blocks attached to the
      poop block, pooping a block may cause some of the player's
      food to drop off -- these blocks go back to being regular
      food -- the goal of this is that pooping events incentive
      enemy players to swarm the player in the hopes of eating
      food that falls off the player
- game ends when all the blocks are eaten
- not all food is equal
    - most food is just food, eat it and you are bigger
    - there is special food
        - confusion food: reverse all controls
        - gassy food: energy bursts (gas) shoot from every outer
          block each time the player moves
            - these bursts interact with other players like
              collisions with a single block
        - speed food: player moves faster
        - oily food: any move (or throwback) causes player to
          slide until they hit an obstacle

# block types

- player
- food
    - does not move
        - has some animation, but not as excited as player
    - player "pushes" against food to "eat it"
    - food becomes part of the player's body when eaten
        - e.g., if player is one block and eats food, the player
          is now two blocks long
        - food retains its color in the player
        - different colors give the player different powers
    - food is different colors
- poop
    - does not move
        - has some animation, but even less excited than food
          animation
    - acts as an obstacle
    - all poop is same color
- teleport
    - `teleport` block moves player to another `teleport` block
      on the board
    - Lily suggested this after she saw my failed attempt at
      screen-wraparound:
        - same motion tween for normal locomotion works nice for teleport
        - when destination is not right next to the player, it's
          a teleportation!
    - one possible use: spawn teleportation blocks when players
      lose parts of their body
        - spawn a block at the edible body part
        - spawn a block near the opponents
        - helps opponents go eat the fallen body parts

# aesthetics
- blocks are squares
    - block size sets the grid of the game
    - everything snaps to this grid
    - movement is quantized by this grid
    - movement is a tween that stops when the player gets to new
      tile
- background is black
    - black is minimum viable
    - animated dark static is next step up
    - crazy rainbow worm infinite space void animation is where I
      really want to go with this
- edible blocks "rainbow cycle"
    - when you eat a block it stops changing color
    - the color of the block when you eat it is whatever color it
      happens to be in the cycle
- when players collide:
    - when a players is hit by a moving player, it is thrown back
        - e.g., if A stands still and B moves into A, A is thrown back
        - e.g., if A and B move into each other, both are thrown back
    - throwback is a tween that overshoots the new tile a little
      and player "bounces back"
    - the number of tiles the player is thrown is equal to the
      number of tiles of the attacker along the row of the attack
      vector
        - e.g., draw a line from victim to attacker
        - if the attacker only has one tile on this line, victim
          is thrown back only one square
- normal animation is a wobble
- moving animation is a super wobble
- normal food animation is nothing special
    - the food becomes part of you, so it matches your wobble
- special food animation communicates what happens
    - eat confusion food animation is a spiral wave
    - eat gassy food animation is a rapid radiating wave
    - eat speed food animation is an increase in wobble amount
      and a decrease in wobble period
    - eat oily food animation replaces wobble with a shear
        - shear direction indicates movement direction:
            - side-to-side shearing is horizontal axis
            - up-and-down shearing is vertical axis
- poop animation is wobble switches to a shake
    - shake increases in magnitude just before pooping
    - after poop, player returns to normal and poop-timer resets
- a poop-timer, about three seconds, starts when the player
  stands still
    - when the poop-timer is up a warning starts:
        - player turns a darker color
        - animation changes from wobble to shake
        - a pooping timer starts
        - the pooping timer is only one second
    - if player moves before the pooping timer is up, the player
      returns to normal
    - else player poops: one of its outer blocks changes to poop
      and is no longer attached to the player
    - if the player poops has only one block left (which is how
      the game starts) then the player poops itself to nothing:
      the player is dead and the game is over
- title scene has a random one-liner that sometimes explains a
  rule of play, sometimes not
    - examples of not-helpful one-liners:
        - grow big or go home
        - try being a bigger version of yourself
    - examples of helpful one-liners:
        - move or you'll poop
        - don't just stand there pooping
        - sometimes it's good to poop
        - you are what you eat

# title screen

- 3 players start out then quickly grow to spell the world EAT
- the individual blocks that makes up the letters move to form
  the word AND
- and they move again to form the word POOP
- the blocks in POOP start shaking, turn to POOP (like popcorn),
  then fall off the screen
- and repeat

# music
- space
- the melody on top of space alternates between the players to
  tell the story of each player
- the melody cycles rhythmically between all players, but when an
  event happens the melody instantly switches to that player
- eating increases the voices for that player
    - draw a bounding box around the player
    - if box contains spaces, add a high-pitched voice
    - if box contains no spaces, take all high-pitched voices and
      compress them down into a perfect harmony at a middle pitch
- pooping decreases voices from "middle pitch" out

# boring stuff

- local multiplayer
    - players are added/removed on the fly when joysticks are
      added/removed
