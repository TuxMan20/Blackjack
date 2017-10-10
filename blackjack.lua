
-- Let the program stops temporarily to create basic animation
function sleep (a)
  local sec = tonumber(os.clock() + a);
  while (os.clock() < sec) do
  end
end

-- Setting the randomness seed
math.randomseed(os.time())

-- Function to copy Tables (keeping a table of a new deck)
function table.clone(org)
  return {table.unpack(org)}
end

-- Clears the Terminal screen (When redrawing the play area)
function clear()
  os.execute("clear")
end

-- Initializing the Player class for user and dealer
Player = {}
Player.__index = Player

function Player:new (o)
     o = o or {}   -- create object if user does not provide one
     setmetatable(o, self)
     self.__index = self
     self.name = ""
     self.choice = 0
     self.total = 0
     self.money = 0
     self.bet = 0
     self.insurance = 0
     self.blackjack = false
     return o
end

function Player:set_name(name)
  self.name = name
end

function Player:hit(deck)
   table.insert(self.hand, draw(deck))
end

-- Give the money back + the bet
function Player:win(amount)
  self.money = self.money + (self.bet * amount)
  self.bet = 0
end

-- Empties the hand and gets ready for a new deal
function Player:empty_hand()
 for i in pairs (self.hand) do
   self.hand[i] = nil
 end
end

-- Draws a random card from the deck "drawFrom" and removes the
-- card each time to make sure it is not drawn twice.
-- Returns the drawn card value as output
function draw(deck)
    local n = #deck
    local pos = math.random(n)
    local cardDrew = deck[pos]
    table.remove(deck, pos)
    return cardDrew
end

-- Draws/Updates the play area on the table
function redrawTable()
  clear()

  io.write("You: ")
  for i = 1, #user.hand do
    io.write(user.hand[i] .. " ")
  end
  io.write("(" .. user:count_hand() .. ")")

  io.write("\nDealer: ")

  if showDealerCards == false then -- Before the dealer turn, his second card is not shown
    io.write(dealer.hand[1] .. " ")
  else
    for i = 1, #dealer.hand do
      io.write(dealer.hand[i] .. " ")
    end
  end
  if showDealerCards == false then -- Before the dealer turn, his second card is not counted
    io.write("(" .. checkSuits(dealer.hand[1]) .. ")")
  else
    io.write("(" .. dealer:count_hand() .. ")")
  end
  io.write("\n\n")
  io.write("Your bet:" .. user.bet .. "\n")
end

function checkSuits(card)
  if card == 'J' or card == 'Q' or card == 'K' then
    return 10
  else
    return card
  end
end

function checkAce(card)
  if card == 'A' then
    return 11
  else
    return card
  end
end

-- Calculates the hand total after every hit
function Player:count_hand()
    local total = 0
    local softHand = false
    local softHandCount = 0

    for i = 1, #self.hand do
      local value = self.hand[i]

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

-- main loop of the game
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
-- TODO: Limit to integers, and prevent alphabetic entries (Causes an infinite loop)
function bet()

  if user.money < 1 then -- If user has 0.50 left, he cannot play it, so the game ends
    clear()
    io.write("You are out of money. Thank you for playing. You may now leave the casino...\n")
    sleep(5)
    os.exit()
  end

  repeat
    user.insurance = 0
    user.bet = 0
    io.write("You have " .. user.money .. "\n" .. "How much do you want to bet: ")
    user.bet = math.floor(io.read("*numbers"))
  until user.bet > 0 and user.bet <= user.money

  user.money = user.money - user.bet
end


-- Deals the first two cards to dealer and player
-- TODO: Check for Blackjack and insurance
function newDeal()
-- Clears the screen and instantiate a new deck to draw from

-- Resets all the flags to default
  user.blackjack = false
  dealer.blackjack = false
  insuranceTaken = false
  skipDealerTurn = false
  showDealerCards = false
  user:empty_hand()
  dealer:empty_hand()

  drawFrom = table.clone(newDeck)

  for i = 1, 2 do
    user:hit(drawFrom)
  end
  --[[for i = 1, 2 do  -- Disabling dealer hits for blackjack testing
    dealer:hit(drawFrom)
  end]]--
  dealer.hand[1] = 'A'
  dealer.hand[2] = 'J'

  redrawTable()
end

-- Start of the Player's turn
function playerTurn()
  while true do

    -- Checks for a dealer blackjack if he shows a 10, user loses. Turn ends.
    if dealer:count_hand() == 21 and checkSuits(dealer.hand[1]) == 10  and user:count_hand() ~= 21 then
      showDealerCards = true
      skipDealerTurn = true
      redrawTable()
      io.write("Dealer has a Blackjack! Better luck next time...")
      break
    -- Checks for a dealer Blackjack if he shows an Ace. Asks for insurance.
    elseif checkAce(dealer.hand[1]) == 11 then
      io.write("Dealer has an Ace up. Do you want to take insurance?\n")
      repeat
        user.choice = 0
        io.write("[y/n]: ")
        user.choice = io.read()
      until user.choice == 'Y' or user.choice == 'y' or user.choice == 'n' or user.choice == 'N'
      if user.choice == 'Y' or user.choice == 'y' or user.choice == nil then
        user.insurance = user.bet / 2
        user.money = user.money - user.insurance
        insuranceTaken = true
      elseif user.choice == 'N' or user.choice == 'n' then
        insuranceTaken = false
      end

      if dealer:count_hand() == 21 and #dealer.hand == 2 then
        if insuranceTaken == true then
          showDealerCards = true
          redrawTable()
          io.write("Dealer has a Blackjack! Since you took insurance, you recover your bet.")
          user.money = user.money + user.bet + user.insurance
          break

        elseif insuranceTaken == false then
          showDealerCards = true
          redrawTable()
          io.write("Dealer has a Blackjack! Since you didn't take insurance.. you LOSE, sir!")
          skipDealerTurn = true
          break
        end
      end
    end


    -- Checks for user blackjack, user wins
    if user:count_hand() == 21 and #user.hand == 2 and dealer:count_hand() ~= 21 then
      user.blackjack = true
      io.write("BLACKJACK!! Your turn is done and you WIN!\n")
      skipDealerTurn = true
      sleep(3)
      break
    end

    io.write("What will you do?\n")
    io.write("(1) Hit\n")
    io.write("(2) Stay\n")
    if #user.hand == 2 then
      io.write("(3) Double\n")
    end

    if user.hand[1] == user.hand[2] then
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
          io.write("\nYou went over 21. Try again.\n")
          skipDealerTurn = true
          sleep(5)
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
      elseif user.choice == 3 then
        if user.money - user.bet >= 0 then
          user.money = user.money - user.bet
          user.bet = user.bet * 2
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
      io.write("Dealer busts! You win " .. user.bet .. " credits!\n")
      user:win(2)
      sleep(4)
      break
    end
  end
end

-- Evaluates the player's and dealer's cards, Returns a numeric value and a winner
function compare()
  if user:count_hand() > dealer:count_hand() and user:count_hand() < 22 then
    io.write("You win! You receive " .. user.bet .. " credits!\n")
    user:win(2)
  elseif user:count_hand() == dealer:count_hand() then
    io.write("Push! Your hand and the dealer's hand are equal\n")
    user:win(1)
  elseif user:count_hand() == 21 and #user.hand == 2 then
    user:win(2.5)
  elseif dealer:count_hand() > user:count_hand() and dealer:count_hand() < 21 then
    io.write("Dealer wins. Please try again.\n")
  end
end


-- First logic of the program: Setting up basic variables.

borrow = 0

newDeck = {"A", 2, 3, 4, 5, 6, 7, 8, 9 , 10, "J", "Q", "K",
 "A", 2, 3, 4, 5, 6, 7, 8, 9 , 10, "J", "Q", "K",
 "A", 2, 3, 4, 5, 6, 7, 8, 9 , 10, "J", "Q", "K",
 "A", 2, 3, 4, 5, 6, 7, 8, 9 , 10, "J", "Q", "K"}

user = Player:new({hand = {}}) -- Instantiates the user and dealer objects
dealer = Player:new({hand = {}})

user.name = "Player"
dealer.name = "Dealer"

user.money = 1000 -- Sets the player starting money

---------------------------------------------------
-- Start of main program, and displays main menu --
---------------------------------------------------

clear()

io.write("\n" .. [[Welcome to Blackjack]] .. "\n")

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
