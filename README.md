# Open-Blackjack
Blackjack game in Lua to be used on OpenOS in the Minecraft Mod 'OpenComputers'
By TuxMan20
Forks are welcomed

- TODO: Complete the game loop
- TODO: Complete game actions (Split, Stay, Double...)
- TODO: Check for blackjacks at first draw (dealer and user)
- TODO: Ask for insurance
- TODO: Pay winnings
- TODO: Complete dealer (CPU) turn
- TODO: Separate the game, functions and class files.
- TODO: Add sleep() between card draws for animation sake (creating tension/anticipation)

- DONE: Place bets
- DONE: Check for game losses (Over 21)
- DONE: Draw the first cards (Begin turn)

Long term goals:
- Storing the player's credit in an external file for persistence (Maybe implementing a crypto for security)
- Adding support for external inventories in Minecraft for in-game items Bets and Payouts
- Adding support for Redstone in Minecraft to have more world interaction (ie: blinking lights when winning)
- Adding a simple GUI compatible with OpenOS
- Porting the game logic to Love2D for a more modern looking game
