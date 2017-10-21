
-- Let the program stops temporarily to create basic animation
function sleep (a)
  -- When inside OpenOS, you delete everything in here and replace with:
  -- os.sleep(a)
  local sec = tonumber(os.clock() + a);
  while (os.clock() < sec) do
  end
end

-- Clears the Terminal screen (When redrawing the play area)
function clear()
  os.execute("clear")
end

-- Function to copy Tables (keeping a table of a new deck)
function table.clone(org)
  return {table.unpack(org)}
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
  for i = 1, #user.hand[user.curHand] do
    io.write(user.hand[user.curHand][i] .. " ")
  end
  io.write("(" .. user:count_hand() .. ")")

  io.write("\nDealer: ")

  if showDealerCards == false then -- Before the dealer turn, his second card is not shown
    io.write(dealer.hand[1][1] .. " ")
  else
    for i = 1, #dealer.hand[1] do
      io.write(dealer.hand[1][i] .. " ")
    end
  end
  if showDealerCards == false then -- Before the dealer turn, his second card is not counted
    io.write("(" .. checkSuits(dealer.hand[1][1]) .. ")")
  else
    io.write("(" .. dealer:count_hand() .. ")")
  end
  io.write("\n\n")
  io.write("Your bet: " .. user.bet[user.curHand] .. "\n")
end

-- Converts the face cards to the value 10
function checkSuits(card)
  if card == 'J' or card == 'Q' or card == 'K' then
    return 10
  else
    return card
  end
end

-- Converts the Aces to the value 11, soft hands are checked during play
function checkAce(card)
  if card == 'A' then
    return 11
  else
    return card
  end
end

newDeck = {"A", 2, 3, 4, 5, 6, 7, 8, 9 , 10, "J", "Q", "K",
 "A", 2, 3, 4, 5, 6, 7, 8, 9 , 10, "J", "Q", "K",
 "A", 2, 3, 4, 5, 6, 7, 8, 9 , 10, "J", "Q", "K",
 "A", 2, 3, 4, 5, 6, 7, 8, 9 , 10, "J", "Q", "K"}
