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
- press space to poop
    - a random block is pooped
    - a pooped block is not editable
    - the player's group is only the blocks that are still
      *attached*
    - define *attached*:
        - a block is attached if it touches on a side
        - touching on a corner is not a connection
- game ends when all the blocks are eaten

# aesthetics
- blocks are squares
    - block size sets the grid of the game
    - everything snaps to this grid
    - movement is quantized by this grid
- background is black
- edible blocks "rainbow cycle"
    - when you eat a block it stops changing color
    - the color of the block when you eat it is whatever color it
      happens to be in the cycle
- game is multiplayer
    - take game controller input to make multiplayer doable
    - develop the game on the keyboard using wasd and space

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
