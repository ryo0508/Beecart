# Beecart

## Requirement

* Redis Server

## Installation

###Adding to your Gemfile

```ruby
gem "beecart"
```

###Create initializer

```ruby
# ./config/initializers/beecart.rb

Beecart.configure do |config|

  # Time to expire your cart in seconds
  config.expire_time = 30

  # Redis Information
  config.redis = {
    host: 'localhost',
    port: 5555
  }

end
```

## How to use?

```ruby
# ./app/controllers/application_controller.rb

include Beecart::CurrentCart
```

```ruby
# ./app/controllers/your_controller.rb

class YourController < ApplicationController
  def index
    @cart = current_cart
  end

  def add_item
    @cart = current_cart
    @cart.add_item(
      item_id:  1,
      price:    5000,
      quantity: 3,
      any_data: ‘you_may_put_any_data’,
      …
    )
  end

  def remove_item
    @cart = current_cart
    @cart.remove_item(params[:key])
  end
end
```

You may call ```current_cart``` method from any controllers you want. 
This method will return ___ShoppingCart object___  which provides functionality to

* Add Item
* Remove Item
* Reset Cart
* Expiret cart
* Sum total price in the cart

Detailed definition can be found in the Doc.

[Check instance methods here](http://rubydoc.info/github/ryo0508/Beecart/master/frames)

## Saving Data in Cart

You may save any data in the cart along with the item data.

```ruby
@cart = current_cart
@cart.change_append_transaction_data(:user_data, {
  name: “Beenos”,
  age:  0
})

puts @cart.data[:user_data][:name]
# => “Beenos”

puts @cart.data[:user_data][:age]
# => 0

```

## TODO

[ ] Customizable Validation
[ ] Adding Custom Payment Methods
