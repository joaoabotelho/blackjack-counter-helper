class PagesController < ApplicationController
  def index
    @cards = Card.order('id DESC').limit(5)
    @plays = Play.order('id DESC').limit(3)
    @running_count = Card.sum(:true_value)
    number_carts_dealt = Card.count
    @left_decks = ((312 - number_carts_dealt)/52.to_f).round(1)
    @true_value = (@running_count / @left_decks.to_f).floor(1)
    bet_unit = 1
    if @true_value < 2
      @bet = bet_unit
    elsif 3 > @true_value and @true_value >= 2
      @bet = bet_unit * 2
    elsif 4 > @true_value and @true_value >= 3
      @bet = bet_unit * 4
    else
      @bet = bet_unit * 12
    end
  end
end
