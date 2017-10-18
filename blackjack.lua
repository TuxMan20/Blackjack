
local dbg = require("debugger")
-- Links the helpers.lua library file to clean up the main code
functions = require("helpers")

-- Setting the randomness seed
math.randomseed(os.time())

-- Initializing the Player class for user and dealer
Player = {}
Player.__index = Player

function Player:new (o)
     o = o or {}   -- create object if user does not provide one
     setmetatable(o, self)
     self.__index = self
     self.name = "" -- Gives a name to the player (currently unused)
     self.choice = 0 -- Keeps track of user's choice
     self.total = 0 -- total of the hand (addind card values)
     self.money = 0 -- Remaining credits
     self.debt = 0 -- Will be used to borrow money when out (currently unused)
     self.curHand = 1 -- Keeps track of the current hand being played and which bet to use
     self.split = 1 -- Keeps track of the total amount of times the hand was split (total number of hands)
     self.bet = {0, 0, 0, 0} -- 4 bets for the 4 possible hands after a Split
     self.insurance = 0 -- Amount being payed for insurance when dealer shows an Ace
     self.blackjack = false
     return o
end

function Player:set_name(name)
  self.name = name
end

function Player:hit(deck)
   table.insert(self.hand[self.curHand], draw(deck))
end

-- Give the money back + the bet
function Player:win(amount)
  self.money = self.money + (self.bet[self.curHand] * amount)
  self.bet = 0
end

-- REMOVED: I just re-declared the tables:
-- ie: user.hand = {{}, {}, {}, {}}
-- Empties the hand and gets ready for a new deal
--[[function Player:empty_hand()
  for i = 1, #self.hand do
    for j in pairs (self.hand) do
      self.hand[i][j] = nil
    end
  end
end]]--

-- Calculates the hand total after every hit
function Player:count_hand()
    local total = 0
    local softHand = false
    local softHandCount = 0

    for i = 1, #self.hand[self.curHand] do
      local value = self.hand[self.curHand][i]

      value = checkSuits(value)

    if checkAce(value) == 11 then
      value = 11
      softHand = true
      softHandCount = softHandCount + 1
    end

      total = total + value
    end

    if total > 21 and softHand == true then
      total = total - (softHandCount * 10)
    end

    return total
end

-------------- main loop of the game --------------------
function game ()
  while true do

    bet()

    newDeal()

    playerTurn()

    dealerTurn()

    compare()

  end
end

-- Asks the user to place a bet
-- TODO: Limit to integers, and prevent alphabetic entries (Causes a crash)
function bet()
  user.curHand = 1 -- Resets the current bet used if the user has Split

  user.bet = {0, 0, 0, 0}

  if user.money < 1 then -- If user has 0.50 left, he cannot play it, so the game ends
    clear()
    io.write("You are out of money. Thank you for playing. You may now leave the casino...\n")
    sleep(5)
    os.exit()
  end

  user.insurance = 0

  repeat
    io.write("You have " .. user.money .. "\n" .. "How much do you want to bet: ")
    user.bet[1] = math.floor(io.read("*n"))
  until user.bet[1] > 0 and user.bet[1] <= user.money

  user.money = user.money - user.bet[1]
end


-- Deals the first two cards to dealer and player
function newDeal()
-- Clears the screen and instantiate a new deck to draw from
-- Resets all the flags to default
  user.blackjack = false
  dealer.blackjack = false
  insuranceTaken = false
  skipDealerTurn = false
  showDealerCards = false

  user.hand = {{}, {}, {}, {}} -- maybe I wont need those if I found the right bug
  dealer.hand = {{}} -- I was resetting the HANDS to 0 instead of the BETS!!

  drawFrom = table.clone(newDeck)

  for i = 1, 2 do
    user:hit(drawFrom)
  end
  --user.hand[1] = '8'
  --user.hand[2] = 'J' -- keeping those for tests

  for i = 1, 2 do
    dealer:hit(drawFrom)
  end
  --dealer.hand[1][1] = '8'
  --dealer.hand[1][2] = '9' -- keeping those for tests
  redrawTable()
end

-- Start of the Player's turn
function playerTurn()
  while true do

    -- Checks for a dealer blackjack if he shows a 10 or Ace, user loses. Turn ends.
    if #user.hand[user.curHand] == 2 then
      if dealer:count_hand() == 21 and checkSuits(dealer.hand[1][1]) == 10  and user:count_hand() ~= 21then
        showDealerCards = true
        skipDealerTurn = true
        dealer.blackjack = true
        redrawTable()
        break
      -- Checks for a dealer Blackjack if he shows an Ace. Asks for insurance.
    elseif checkAce(dealer.hand[1][1]) == 11 and #user.hand[1] == 2 then
        io.write("Dealer has an Ace up. Do you want to take insurance?\n")
        io.write("[y/n]: ")
        repeat
          user.choice = 0
          user.choice = io.read()
        until user.choice == 'Y' or user.choice == 'y' or user.choice == 'n' or user.choice == 'N'
        if user.choice == 'Y' or user.choice == 'y' and user:count_hand() == 21 then -- Taking even money on a Blackjack
          skipDealerTurn = true
          showDealerCards = true
          insuranceTaken = true
          user.blackjack = true
          break
        elseif user.choice == 'Y' or user.choice == 'y' then
          user.insurance = user.bet[user.curHand] / 2
          user.money = user.money - user.insurance
          insuranceTaken = true
        elseif user.choice == 'N' or user.choice == 'n' then
          insuranceTaken = false
        end

        if dealer:count_hand() == 21 and #dealer.hand[1] == 2 then
          if insuranceTaken == true then
            dealer.blackjack = true
            showDealerCards = true
            redrawTable()
            break

          elseif insuranceTaken == false then
            dealer.blackjack = true
            showDealerCards = true
            redrawTable()
            skipDealerTurn = true
            break
          end
        else
          sleep(3)
          if insuranceTaken == true then
            io.write("Dealer has no blackjack. You lose the insurance.\n")
          else
            io.write("Dealer has no blackjack.\n")
          end
          sleep(3)
          redrawTable()
        end
      end
    end


    -- Checks for user blackjack, user wins
    if user:count_hand() == 21 and #user.hand[1] == 2 then
      user.blackjack = true
      skipDealerTurn = true
      sleep(3)
      break
    end

    io.write("What will you do?\n")
    io.write("(1) Hit\n")
    io.write("(2) Stay\n")
    if #user.hand[user.curHand] == 2 then
      io.write("(3) Double\n")
    end

    if user.hand[user.curHand][1] == user.hand[user.curHand][2] then
      io.write("(4) Split\n")
    end
    io.write("(5) Quit\n")

      repeat
        user.choice = 0
        io.write("Command: ")
        user.choice = math.floor(io.read("*numbers"))
      until user.choice > 0 and user.choice <= 5 and user.choice ~= nil

      -- Choice #1: Hit and draw a card, checks for going over 21
      if user.choice == 1 then
        user:hit(drawFrom)
        redrawTable()

        -- If user goes above 21, he loses
        if user:count_hand() > 21 then
          skipDealerTurn = true
          showDealerCards = true
          sleep(1)
          clear()
          break
        -- If user has exactly 21, his turn is done
        elseif user:count_hand() == 21 then
          io.write("\nTWENTY ONE!! Your turn is done!\n")
          sleep(5)
          break
        end

      -- Choice #2: Stand, simply breaks out of the loop and goes to dealer turn
      elseif user.choice == 2 then
        clear()
        break

      -- Choice #3: Double: First 2 cards only, double the bet, hit ONE card and goes to the dealer turn
      elseif user.choice == 3 and #user.hand[user.curHand] == 2 then
        if user.money - user.bet[user.curHand] >= 0 then
          user.money = user.money - user.bet[user.curHand]
          user.bet[user.curHand] = user.bet[user.curHand] * 2
          clear()
          redrawTable()
          io.write("Double down for one card! Good luck! Your turn is done!\n")
          sleep(3)
          user:hit(drawFrom)

          if user:count_hand() > 21 then
            redrawTable()
            io.write("\nYou went over 21. Try again.\n")
            showDealerCards = true
            skipDealerTurn = true
            sleep(5)
            clear()
            break
          elseif user:count_hand() == 21 then
            io.write("\nTWENTY ONE!! Your turn is done!\n")
            sleep(5)
            break
          end

          redrawTable()
          break
        else
          io.write("You don't have enough credit to double your bet.\n")
          sleep(3)
          redrawTable()
        end

      -- Choice #4: Split. Only if the two cards are the same. Create an additional hand to be played independently
      elseif user.choice == 4 then
        -- TODO: Split()
        os.exit()

      -- Choice #5: Quit. Forfeit the hand and the bet and walk away
      elseif user.choice == 5 then
        os.exit()
      end --End the choices "if"s
  end
end

-- Dealer plays until he hits 17 (Also soft 17s)
function dealerTurn()
showDealerCards = true
redrawTable()
sleep(2)
io.write("Dealer's turn...\n")

  while dealer:count_hand() < 17 do
    if skipDealerTurn == true then
      break
    end
    dealer:hit(drawFrom)
    clear()
    redrawTable()
    io.write("Dealer's turn...\n")
    sleep(3)
    if dealer:count_hand() > 21 then
      io.write("Dealer busts! You win " .. user.bet[user.curHand] .. " credits!\n")
      user:win(2)
      sleep(4)
      break
    end
  end
end

-- Evaluates the player's and dealer's cards, Returns a numeric value and a winner
-- Contains the win/loss conditions for every scenarios
--(I made the win() function to also give back the bet, which explains the win(2).
-- User gets back his bet + his winnings, hence, 2 times his bet.)
function compare()

  -- User has a blackjack and the dealer doesn't, users wins 1.5x
  if user.blackjack == true and dealer:count_hand() ~= 21 then
    io.write("BLACKJACK!! Your turn is done and you WIN " .. user.bet[user.curHand] * 1.5 .. " credits!\n")
    user:win(2.5)

  -- User has a higher total than the dealer, less than 22, user wins 1x
  elseif user:count_hand() > dealer:count_hand() and user:count_hand() < 22 then
    if user.split > 1 then
      io.write("Hand " .. user.curHand .. ": ")
    end
    io.write("You win! You receive " .. user.bet[user.curHand] .. " credits!\n")
    user:win(2)

  -- User busts, over 21, user loses
  elseif user:count_hand() > 21 then
    io.write("\nYou went over 21. Try again.\n")

  -- User has a blackjack and takes even money on insurance, user wins 1x
  elseif user.blackjack == true and insuranceTaken == true then
    io.write("You took even money on a Blackjack. You win " .. user.bet[user.curHand] .. " credits.\n")
    user:win(2)

  -- User and Dealer have equal totals, user is even
  elseif user:count_hand() == dealer:count_hand() then
    io.write("Push! Your hand and the dealer's hand are equal\n")
    user:win(1)

  -- Dealer has a higher total, user loses
  elseif dealer:count_hand() > user:count_hand() and dealer:count_hand() < 21 then
    io.write("Dealer wins. Please try again.\n")

  -- Dealer has a blackjack, no insurance, user loses.
  elseif dealer.blackjack == true and insuranceTaken == false then
    io.write("Dealer has a Blackjack! Better luck next time...\n")

  -- Dealer has a blackjack, with insurance, user is even
  elseif dealer.blackjack == true and insuranceTaken == true then
    io.write("Dealer has a Blackjack! Since you took insurance you recover your bet\n")
    user:win(1)

  end
end


-- First logic of the program: Setting up basic variables.

user = Player:new({hand = {{}, {}, {}, {}}}) -- Instantiates the user and dealer objects
dealer = Player:new({hand = {{}}})

user.name = "Player"
dealer.name = "Dealer"

user.money = 1000 -- Sets the player starting money

---------------------------------------------------
-- Start of main program, and displays main menu --
---------------------------------------------------

clear()

io.write("\n" .. [[
 _____                _____ _         _     _         _
|     |___ ___ ___   | __  | |___ ___| |_  |_|___ ___| |_
|  |  | . | -_|   |  | __ -| | .'|  _| '_| | | .'|  _| '_|
|_____|  _|___|_|_|  |_____|_|__,|___|_,_|_| |__,|___|_,_|
      |_|                                |___|            ]] .. "\n")

sleep(1)

io.write("\n" .. [[By TuxMan20]] .. "\n\n")

sleep(1)

io.write("Current credit: " .. user.money .. "\n\n")

sleep(1)

io.write("\n" .. [[Please choose an option:
(1) New Game
(2) Add Credits
(3) Quit]] .. "\n\n")

repeat
  io.write("Command: ")
  user.choice = math.floor(io.read("*numbers"))
until user.choice > 0 and user.choice <= 3

if user.choice == 1 then
  game()
elseif user.choice == 2 then
  -- TODO: addCredit()
  io.write("TODO: Choice 2\n")
elseif user.choice == 3 then
  os.exit()
end
