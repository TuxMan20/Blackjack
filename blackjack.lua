
-- Kepping this library for now as it's a nice gdb-like debugger
local dbg = require("debugger")

-- Links the helpers.lua library file to clean up the main code
local functions = require("helpers")

-- Players object
local Players = require("players")

-- Setting the randomness seed
math.randomseed(os.time())


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
------------------------------------------------------------

-- Asks the user to place a bet
function bet()
  user.curHand = 1 -- Resets the current hand used if the user had Split

  user.bet = {0, 0, 0, 0}

  if user.money < 1 then -- If user has 0.50 left, he cannot play it, so the game ends
    clear()
    io.write("You are out of money. Thank you for playing. You may now leave the casino...\n")
    sleep(5)
    main()
  end

  user.insurance = 0

  io.write("You have " .. user.money .. "\n" .. "How much do you want to bet? (Or bet 0 to return to the main menu)\n")
  repeat
    io.write("Amount: ")
    user.bet[1] = tonumber(io.read("*line"))
  until user.bet[1] >= 0 and user.bet[1] <= user.money

  if user.bet[1] == 0 then
    main()
  else
    user.bet[1] = math.floor(user.bet[1])
    user.money = user.money - user.bet[1]
  end
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
  user.split = 1
  user.hand = {{}, {}, {}, {}}
  dealer.hand = {{}}

  drawFrom = table.clone(newDeck)

  for i = 1, 2 do
    user:hit(drawFrom)
  end
  --user.hand[1][1] = 'K'
  --user.hand[1][2] = 10 -- keeping those for tests

  for i = 1, 2 do
    dealer:hit(drawFrom)
  end
  --dealer.hand[1][1] = '10'
  --dealer.hand[1][2] = '6' -- keeping those for tests
  redrawTable()
end

-- Start of the Player's turn
function playerTurn()
  --while user.curHand <= user.split do

    while true do

      -- Checks for a dealer blackjack if he shows a 10 or Ace, user loses. Turn ends.
      if #user.hand[user.curHand] == 2 then
        if count_hand(dealer.hand[1]) == 21 and checkSuits(dealer.hand[1][1]) == 10  and count_hand(user.hand[user.curHand]) ~= 21 then
          showDealerCards = true
          skipDealerTurn = true
          dealer.blackjack = true
          redrawTable()
          break
        -- Checks for a dealer Blackjack if he shows an Ace. Asks for insurance.
      elseif checkAce(dealer.hand[1][1]) == 11 and #user.hand[1] == 2 then
          io.write("Dealer has an Ace up. Do you want to take insurance?\n")
          repeat
            io.write("[y/n]: ")
            user.choice = 0
            user.choice = io.read("*line")
          until user.choice == 'Y' or user.choice == 'y' or user.choice == 'n' or user.choice == 'N'
          if user.choice == 'Y' or user.choice == 'y' and count_hand(user.hand[user.curHand]) == 21 then -- Taking even money on a Blackjack
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

          if count_hand(dealer.hand[1]) == 21 and #dealer.hand[1] == 2 then
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
      if count_hand(user.hand[user.curHand]) == 21 and #user.hand[1] == 2 then
        user.blackjack = true
        skipDealerTurn = true
        sleep(3)
        break
      end
------ Main player's Loop considering player's hands and Split -------
repeat
      if #user.hand[user.curHand] < 2 then
        user:hit(drawFrom)
        if count_hand(user.hand[user.curHand]) == 21 and user.split > 1 then
          io.write("\nTWENTY ONE!! This hand is done!\n")
          sleep(2)
          user.curHand = user.curHand + 1
        end
        redrawTable()
      end
      io.write("What will you do?\n")
      io.write("(1) Hit\n")
      io.write("(2) Stay\n")
      if #user.hand[user.curHand] == 2 then
        io.write("(3) Double\n")
      end

      if checkSuits(user.hand[user.curHand][1]) == checkSuits(user.hand[user.curHand][2]) and user.split < 4 then
        io.write("(4) Split\n")
      end
      io.write("(5) Quit\n")

        repeat
          user.choice = 0
          io.write("Command: ")
          user.choice = tonumber(io.read("*line"))
        until user.choice > 0 and user.choice <= 5 and user.choice ~= nil

        -- Choice #1: Hit and draw a card, checks for going over 21
        if user.choice == 1 then
          user:hit(drawFrom)
          sleep(1)
          redrawTable()

          -- If user goes above 21, he loses
          if count_hand(user.hand[user.curHand]) > 21 then
            skipDealerTurn = true
            showDealerCards = true
            sleep(1)
            clear()
            user.curHand = user.curHand + 1

          -- If user has exactly 21, his turn is done
          elseif count_hand(user.hand[user.curHand]) == 21 then
            io.write("\nTWENTY ONE!! Your turn is done!\n")
            sleep(5)
            user.curHand = user.curHand + 1
          end

        -- Choice #2: Stand, simply breaks out of the loop and goes to dealer turn
        elseif user.choice == 2 then
          clear()
          user.curHand = user.curHand + 1

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

            if count_hand(user.hand[user.curHand]) > 21 then
              redrawTable()
              io.write("\nYou went over 21. Try again.\n")
              skipDealerTurn = true
              sleep(3)
              clear()
              user.curHand = user.curHand + 1

            elseif count_hand(user.hand[user.curHand]) == 21 then
              io.write("\nTWENTY ONE!! Your turn is done!\n")
              sleep(5)
              user.curHand = user.curHand + 1
            end

            redrawTable()
            user.curHand = user.curHand + 1

          else
            io.write("You don't have enough credit to double your bet.\n")
            sleep(3)
            redrawTable()
          end

        -- Choice #4: Split. Only if the two cards are the same. Create an additional hand to be played independently
      elseif user.choice == 4 and checkSuits(user.hand[user.curHand][1]) == checkSuits(user.hand[user.curHand][2]) and #user.hand[user.curHand] == 2 then
          if user.money - user.bet[user.curHand] >= 0 then
            user.split = user.split + 1
            table.insert(user.hand[user.curHand+1], user.hand[user.curHand][2])
            table.remove(user.hand[user.curHand], 2)
            user.bet[user.curHand + 1] = user.bet[1]
            user.money = user.money - user.bet[1]
            redrawTable()
          else
            io.write("You don't have enough credit to split your hand.\n")
            sleep(2)
            redrawTable()
          end

        -- Choice #5: Quit. Forfeit the hand and the bet, goes back to main menu
        elseif user.choice == 5 then
          io.write("Are you sure you want to quit?\n")
          repeat
            io.write("[y/n]: ")
            user.choice = 0
            user.choice = io.read("*line")
          until user.choice == 'Y' or user.choice == 'y' or user.choice == 'n' or user.choice == 'N'
          if user.choice == 'Y' or user.choice == 'y' then
            main()
          else
            redrawTable()
          end
        end --End the choices "if"s
      until user.curHand > user.split
      break
    end
end

-- Dealer plays until he hits any 17
function dealerTurn()
showDealerCards = true
redrawTable()
sleep(2)
io.write("Dealer's turn...\n")

  while count_hand(dealer.hand[1]) < 17 do
    if skipDealerTurn == true and user.split == 1 then
      break
    end
    dealer:hit(drawFrom)
    clear()
    redrawTable()
    io.write("Dealer's turn...\n")
    sleep(3)
    if count_hand(dealer.hand[1]) > 21 then
      sleep(1)
      break
    end
  end
end

-- Evaluates the player's and dealer's cards, Returns a numeric value and a winner
-- Contains the win/loss conditions for every scenarios
--(I made the win() function to also give back the bet, which explains the win(2).
-- User gets back his bet + his winnings, hence, 2 times his bet.)
function compare()

local curHand = 0
io.write("\n")
for i = 1, user.split do
  local curHand = i

  if user.split > 1 then
    io.write("Hand " .. curHand .. ": ")
  end
    -- Dealer busts. User wins 1x on each hand lower than 22
    if count_hand(dealer.hand[1]) > 21 then
      io.write("Dealer busts! You win " .. user.bet[curHand] .. " credits!\n")
      user:win(2, i)

    -- User has a blackjack and the dealer doesn't, users wins 1.5x
    elseif user.blackjack == true and count_hand(dealer.hand[1]) ~= 21 then
      io.write("BLACKJACK!! Your turn is done and you WIN " .. user.bet[curHand] * 1.5 .. " credits!\n")
      user:win(2.5, i)

    -- User has a higher total than the dealer, less than 22, user wins 1x
  elseif count_hand(user.hand[curHand]) > count_hand(dealer.hand[1]) and count_hand(user.hand[curHand]) < 22 then
      io.write("You win! You receive " .. user.bet[curHand] .. " credits!\n")
      user:win(2, i)

    -- User busts, over 21, user loses
    elseif count_hand(user.hand[curHand]) > 21 then
      io.write("You went over 21. Try again.\n")

    -- User has a blackjack and takes even money on insurance, user wins 1x
    elseif user.blackjack == true and insuranceTaken == true then
      io.write("You took even money on a Blackjack. You win " .. user.bet[curHand] .. " credits.\n")
      user:win(2, i)

    -- User and Dealer have equal totals, user is even
    elseif count_hand(user.hand[curHand]) == count_hand(dealer.hand[1]) then
      io.write("Push! Your hand and the dealer's hand are equal\n")
      user:win(1, i)

    -- Dealer has a higher total, user loses
    elseif count_hand(dealer.hand[1]) > count_hand(user.hand[curHand]) and count_hand(dealer.hand[1]) < 21 then
      io.write("Dealer wins. Please try again.\n")

    -- Dealer has a blackjack, no insurance, user loses.
    elseif dealer.blackjack == true and insuranceTaken == false then
      io.write("Dealer has a Blackjack! Better luck next time...\n")

    -- Dealer has a blackjack, with insurance, user is even
    elseif dealer.blackjack == true and insuranceTaken == true then
      io.write("Dealer has a Blackjack! Since you took insurance you recover your bet\n")
      user:win(1)
    end
    io.write("\n")
  end
end

---------------------------------------------------
-- Start of main program, and displays main menu --
---------------------------------------------------
function main()

  clear()

  io.write("\n" ..[[
   _____                _____ _         _     _         _
  |     |___ ___ ___   | __  | |___ ___| |_  |_|___ ___| |_
  |  |  | . | -_|   |  | __ -| | .'|  _| '_| | | .'|  _| '_|
  |_____|  _|___|_|_|  |_____|_|__,|___|_,_|_| |__,|___|_,_|
        |_|                                |___|            ]] .."\n")

  sleep(1)

  io.write("\n" .. "By TuxMan20" .. "\n\n")

  sleep(1)

  if user.debt > 0 then
    io.write("Current debt: " .. user.debt .. "\n")
  end
  io.write("Current credit: " .. user.money .. "\n")

  sleep(1)

  io.write("\n" .. [[Please choose an option:
  (1) New Game
  (2) Add Credits
  (3) Quit]] .. "\n\n")

  repeat
    io.write("Command: ")
    user.choice = tonumber(io.read("*line"))
  until user.choice > 0 and user.choice <= 3

  if user.choice == 1 then
    game()

  elseif user.choice == 2 then
    io.write("How much do you need to buy? (Maximum 10,000$)\n")
    io.write("Remember you will have to repay your debts...\n")
    repeat
      io.write("Amount: ")
      user.debt = tonumber(io.read("*line"))
    until user.debt > 0 and user.debt <= 10000

    user.debt = math.floor(user.debt)
    user.money = user.money + user.debt
    main()

  elseif user.choice == 3 then
    io.write("Are you sure you want to quit?\n")
    repeat
      io.write("[y/n]: ")
      user.choice = 0
      user.choice = io.read("*line")
    until user.choice == 'Y' or user.choice == 'y' or user.choice == 'n' or user.choice == 'N'
    if user.choice == 'Y' or user.choice == 'y' then
      os.exit()
    else
      main()
    end
  end
end

user = Player:new({hand = {{}, {}, {}, {}}}) -- Instantiates the user and dealer objects
dealer = Player:new({hand = {{}}})

user.name = "Player"
dealer.name = "Dealer"

user.money = 1000 -- Sets the player starting money

main()
