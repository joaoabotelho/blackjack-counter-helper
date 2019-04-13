# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
#
def seed_cards
  all_cards = %w(2 3 4 5 6 7 8 9 10 J D R A)

  all_cards.each { |x|

    if all_cards[8, 4].include? x
      value= 10
    elsif all_cards.last == x
      value = 11
    else
      value = x.to_i
    end

     if all_cards[0, 5].include? x
      true_value= 1
     elsif all_cards[5,3].include? x
       true_value = 0
     else
       true_value = -1
     end

    Card.create(
        symbol: "#{x}",
        value: value,
        true_value: true_value,
    )
  }
end

seed_cards