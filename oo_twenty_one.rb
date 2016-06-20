# frozen_string_literal: true
class Participant
  attr_accessor :hand, :score

  def initialize
    @hand = []
    @score = 0
  end
end

module Hand
  def display_hand
    rendered_hand = hand.map { |card| build_card(card) }

    9.times do |index|
      puts rendered_hand.map { |card| card.lines[index].chomp.lstrip }.join(' ')
    end
  end

  def total
    total = 0
    hand.each do |card|
      total += if card[0] == "A"
                 11
               elsif card[0].to_i == 0
                 10
               else
                 card[0]
               end
    end
    hand.flatten.select { |value| value == "A" }.count.times do
      total -= 10 if total > 21
    end

    total
  end

  def display_total
    puts "The current total for the hand is: #{total}"
  end

  def busted?
    total > 21
  end

  private

  def build_card(card)
    <<-CARD
      +-----------+
      |#{card[0]}#{' ' * (card[0] == 10 ? 9 : 10)}|
      |           |
      |           |
      |     #{card[1]}     |
      |           |
      |           |
      |#{' ' * (card[0] == 10 ? 9 : 10) + card[0].to_s}|
      +-----------+
    CARD
  end
end

class Player < Participant
  include Hand

  attr_accessor :choice

  def initialize
    super
    @choice = nil
  end
end

class Dealer < Participant
  include Hand

  # rubocop:disable Metrics/AbcSize
  def display_initial_hand
    puts ''
    puts <<-CARDS
+-----------+ +-----------+
|#{hand[0][0]}#{' ' * (hand[0][0] == 10 ? 9 : 10)}|\
 |           |
|           | |           |
|           | |           |
|     #{hand[0][1]}     | |           |
|           | |           |
|           | |           |
|#{' ' * (hand[0][0] == 10 ? 9 : 10) + hand[0][0].to_s}|\
 |           |
+-----------+ +-----------+
    CARDS
  end
  # rubocop:enable Metrics/AbcSize
end

class Deck
  VALUES = (2..10).to_a + %w(J Q K A)
  SUITS = %w(H D S C).freeze

  attr_accessor :cards

  def initialize
    @cards = VALUES.product(SUITS)
    cards.shuffle!
  end

  def deal
    cards.pop
  end
end

class Game
  DEALER_STAY_VALUE = 16
  attr_accessor :deck, :human, :dealer

  def initialize
    @deck = Deck.new
    @human = Player.new
    @dealer = Dealer.new
  end

  def start
    display_welcome_message
    loop do
      loop do
        play_round
        determine_round
        break if win_game?
      end

      reset_score
      break unless play_again?
    end
    display_goodbye_message
  end

  private

  def deal_cards
    2.times do
      human.hand << deck.deal
      dealer.hand << deck.deal
    end
  end

  def display_card_table_players_turn
    system('clear') || system('cls')
    display_games_played
    dealer.display_initial_hand
    human.display_hand
    human.display_total
  end

  def display_card_table_dealers_turn
    system('clear') || system('cls')
    display_games_played
    dealer.display_hand
    dealer.display_total
    human.display_hand
    human.display_total
  end

  def display_games_played
    puts "Player Wins: #{human.score} -- Dealer Wins: #{dealer.score}"
  end

  def display_welcome_message
    system('clear') || system('cls')
    puts "Welcome to Twenty-one!"
    sleep(1)
  end

  def display_goodbye_message
    puts "Goodbye. Thanks for Playing!"
  end

  def deal_card(player)
    player.hand << deck.deal
  end

  def player_chooses_hit_or_stay
    loop do
      puts 'Would you like to Hit or Stay? (h or s): '
      human.choice = gets.chomp.downcase
      break if human.choice == 'h' || human.choice == 's'
      puts 'Sorry, you must enter a valid response.'
    end
  end

  def player_choices
    loop do
      player_chooses_hit_or_stay
      if human.choice == 'h'
        deal_card(human)
        display_card_table_players_turn
        puts 'You busted!' if human.busted?
        break if human.busted?
      else
        break
      end
    end
  end

  def player_turn
    deal_cards
    display_card_table_players_turn
    player_choices
  end

  def dealers_choices
    while dealer.total < DEALER_STAY_VALUE
      display_card_table_dealers_turn
      deal_card(dealer)
      break if dealer.busted?
    end

    display_card_table_dealers_turn
    puts "Dealer Busted!" if dealer.busted?
  end

  def dealer_turn
    display_card_table_dealers_turn
    dealers_choices
  end

  def human_wins?
    human.total > dealer.total && !human.busted?
  end

  def computer_wins?
    dealer.total > human.total && !dealer.busted?
  end

  def compare_hands
    if dealer.busted? || human_wins?
      puts "Player Wins!"
    elsif human.busted? || computer_wins?
      puts "Dealer Wins!"
    else
      puts "It's a push!"
    end
  end

  def play_round
    loop do
      player_turn
      break if human.busted?
      dealer_turn
      break
    end
  end

  def determine_round
    compare_hands
    prompt_for_continue
    add_points
    reset_round
  end

  def play_again?
    response = ''
    loop do
      puts "Would you like to play again? (y or n): "
      response = gets.chomp.downcase
      break if response == 'y' || response == 'n'
      puts "Sorry, you must provide a valid response."
    end

    return true if response == 'y'
    return false if response == 'n'
  end

  def prompt_for_continue
    puts "Press any key to continue."
    gets.chomp
  end

  def reset_round
    @deck = Deck.new
    human.hand = []
    dealer.hand = []
  end

  def add_points
    if dealer.busted? || human_wins?
      human.score += 1
    elsif human.busted? || computer_wins?
      dealer.score += 1
    end
  end

  def reset_score
    human.score = 0
    dealer.score = 0
  end
end

def win_game?
  human.score == 5 || dealer.score == 5
end
Game.new.start
