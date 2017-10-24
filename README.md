# Open-Blackjack
Blackjack game in Lua to be used on OpenOS in the Minecraft Mod 'OpenComputers'


By TuxMan20


Forks are welcomed

- TODO: Various bug fixes, adjustments
- TODO: Adding a simple GUI compatible with OpenOS
-           - Maybe the one from Dustpuppy     (https://oc.cil.li/index.php?/topic/997-my-gui-now-with-visual-editor/)
- TODO: Porting the game logic to Love2D for a more modern looking game


- DONE: Add sleep() between card draws for animation sake (creating tension/anticipation)
- DONE: Complete game actions (Split)
- DONE: Separate the game, functions and class files.
- DONE: Ask for insurance ("My god! it's full of IFs")
- DONE: Pay winnings
- DONE: Check for blackjacks at first draw (dealer and user)
- DONE: Complete the game loop
- DONE: Complete game actions (Stay, Double...)
- DONE: Complete dealer (CPU) turn
- DONE: Place bets
- DONE: Check for game losses (Over 21)
- DONE: Draw the first cards (Begin turn)

Long term goals:
- Storing the player's credit in an external file for persistence (Maybe implementing a crypto for security)
- Adding support for external inventories in Minecraft for in-game items Bets and Payouts
- Adding support for Redstone in Minecraft to have more world interaction (ie: blinking lights when winning)
