json.extract! card, :id, :symbol, :value, :true_value, :created_at, :updated_at
json.url card_url(card, format: :json)
