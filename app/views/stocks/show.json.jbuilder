json.ingredients @ingredient_quantities do |ingredient_quantity|

json.name ingredient_quantity.ingredient.name
json.quantity ingredient_quantity.quantity
json.unit ingredient_quantity.unit
end