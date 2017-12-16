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
     self.debt = 0 -- Will be used to borrow money when out
     self.curHand = 1 -- Keeps track of the current hand being played and which bet to use
     self.split = 1 -- Keeps track of the total amount of times the hand was split (total number of hands)
     self.bet = {0, 0, 0, 0} -- 4 bets for the 4 possible hands after a Split
     self.insurance = 0 -- Amount being payed for insurance when dealer shows an Ace
     self.blackjack = false
     return o
end

-- I don't really use the names yet
function Player:set_name(name)
  self.name = name
end

function Player:hit(deck)
   table.insert(self.hand[self.curHand], draw(deck))
end

-- Give the money back + the bet
function Player:win(amount, pos)
  self.money = self.money + (self.bet[pos] * amount)
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
function count_hand(hand)
    local total = 0
    local softHand = false
    local softHandCount = 0

    for i = 1, #hand do
      local value = hand[i]

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
