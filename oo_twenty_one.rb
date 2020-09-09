# Participant encapsulates logic for both Player/Dealer classes.
class Participant
  attr_accessor :cards

  def initialize
    @cards = []
  end

  def hit(card)
    cards << card
    change_ace_value
  end

  def busted?
    total > 21
  end

  def change_ace_value
    cards.each do |card|
      card.value = 1 if total > 21 && card.value == 11
    end
  end

  def display_cards
    cards.join(', ')
  end

  def new_hand
    @cards = []
  end

  def total
    cards.map(&:value).sum
  end
end

# Player inherits all of its states/methods from the Participant class.
class Player < Participant
  attr_accessor :name

  def initialize(player_name)
    super()
    @name = player_name
  end
end

# Dealer differs from Player with the less_than_seventeen method.
class Dealer < Participant
  def less_than_seventeen
    total < 17
  end
end

# Represents 52-card deck via an array of Card objects. (@cards)
class Deck
  SUITS = %w(Hearts Spades Clubs Diamonds).freeze
  
  RANKS = { '2' => 2, '3' => 3, '4' => 4, '5' => 5, '6' => 6, '7' => 7,
            '8' => 8, '9' => 9, '10' => 10, 'Jack' => 10, 'Queen' => 10,
            'King' => 10, 'Ace' => 11 }.freeze

  attr_accessor :cards

  def initialize
    @cards = []
    SUITS.each do |suit|
      RANKS.each do |rank, value|
        @cards << Card.new(suit, rank, value)
      end
    end
    @cards.shuffle!
  end

  def deal
    cards.pop
  end
end

# Represents an individual card with suit, rank, and value states.
class Card
  attr_reader :suit, :rank
  attr_accessor :value

  def initialize(suit, rank, value)
    @suit = suit
    @rank = rank
    @value = value
  end

  def to_s
    "#{rank} of #{suit}"
  end
end

# rubocop: disable Metrics/ClassLength
# Engine of Twenty One game.
class Game
  attr_accessor :player, :dealer, :deck

  def initialize
    @deck = Deck.new
    @player = Player.new('Player 1')
    @dealer = Dealer.new
  end

  def deal_cards
    2.times { player.cards << deck.deal }
    2.times { dealer.cards << deck.deal }
  end

  def clear
    system 'clear'
  end

  def hit_or_stay?(answer)
    case answer.downcase
    when 'hit'
      player.hit(deck.deal)
      'hit'
    when 'stay'
      'stay'
    else
      'invalid'
    end
  end

  def player_turn
    loop do
      clear
      prompt
      display_cards_and_totals
      case hit_or_stay?(gets.chomp)
      when 'hit' then break if player.busted?
      when 'stay' then break
      when 'invalid' then invalid_answer_message
      end
    end
  end

  def dealer_turn
    loop do
      dealer.hit(deck.deal)
      break if dealer.busted? || !dealer.less_than_seventeen
    end
  end

  def busted_messages
    dealer_busted_message if dealer.busted?
    player_busted_message if player.busted?
  end

  def tie_message
    puts "It's a tie!" if tie?
  end

  def player_wins_message
    puts 'You win!' if player_wins?
  end

  def dealer_wins_message
    puts 'Dealer wins!' if dealer_wins?
  end

  def show_result
    clear
    busted_messages
    tie_message
    player_wins_message
    dealer_wins_message
    display_cards_and_totals
  end

  # rubocop: disable Metrics/LineLength
  def display_cards_and_totals
    puts "Your cards: #{player.display_cards} | Your score: #{player.total}"
    puts "Dealer's cards: #{dealer.display_cards} | Dealer's score: #{dealer.total}"
  end

  def tie?
    (player.busted? && dealer.busted?) || (player.total == dealer.total)
  end

  def player_wins?
    return true if dealer.busted? && !player.busted?
    return false if player.busted?
    player.total > dealer.total
  end

  def dealer_wins?
    return true if player.busted? && !dealer.busted?
    return false if dealer.busted?
    dealer.total > player.total
  end

  def prompt
    puts "Your move, #{player.name}. Hit or stay?"
  end

  def dealer_busted_message
    puts "The dealer has busted with a total of #{dealer.total}!"
  end

  def player_busted_message
    puts "Oops! Looks like you've busted with a total of #{player.total}."
  end

  def invalid_answer_message
    puts "Oops! Invalid response. Type 'hit' or 'stay'!"
  end

  def show_initial_cards
    puts "Your cards: #{player.cards.join(', ')}"
    puts "Dealer's cards: #{dealer.cards.join(', ')}"
  end

  def name_prompt
    clear
    puts "What's your name?"
    player_name = gets.chomp
    player.name = player_name
  end

  def reset
    self.deck = Deck.new
    player.new_hand
    dealer.new_hand
  end

  def play_again_error_message
    puts "Invalid input. Please enter 'y' or 'n':"
  end

  def play_again?
    answer = nil
    loop do
      puts 'Would you like to play again? (y/n)'
      answer = gets.chomp.downcase
      break if %w(y n).include? answer
      clear
      puts 'Sorry, must be y or n:'
    end
    answer == 'y'
  end

  def goodbye_message
    clear
    puts "Thank you for playing Twenty One #{player.name}!"
  end

  def start
    name_prompt
    loop do
      deal_cards
      player_turn
      dealer_turn
      show_result
      break unless play_again?
      reset
    end
    goodbye_message
  end
end

Game.new.start
