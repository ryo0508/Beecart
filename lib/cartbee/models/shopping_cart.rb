# ---------------------------------------------
#
# 基本的にはこのような形でカートは保存されることが期待される。
#
# items:
#   random_key:
#     title:    'your_item_title'
#     price:    'your_item_price'
#     quantity: 'your_item_quantity'
#     ...
#   random_key:
#     title: 'your_item_title'
#     price: 'your_item_price'
#     ...
# user_id: 'your_user_id'
#
# shipping_address:
#   zip_code: 'customer_zip_code'
#   prefecture: 'customer_prefecture'
#   city: 'customer_city'
#   address1: 'customer_address1'
#   address2: 'customer_address2'
#   ...
#
# billing_address:
#   zip_code: 'customer_zip_code'
#   prefecture: 'customer_prefecture'
#   city: 'customer_city'
#   address1: 'customer_address1'
#   address2: 'customer_address2'
#   ...
# credit_card:
#   card_number: 'customer_card_number'
#   cvc: 'customer_cvc_number'
#   exp_month: 'expiration_month'
#   exp_year: 'expiration_year'
#
# shipping_instruction:
#   ...
#
# created_at: 'cart_create_time'
# updated_at: 'cart_update_time'
#
# ---------------------------------------------

module Cartbee
  class ShoppingCart
    attr_reader :key

    ShippingColumns = {
      shipping_address: [
        :name, :zip, :province, :city, :address1, :address2, :tel
      ],
      billing_address: [
        :name, :zip, :province, :city, :address1,:address2, :tel
      ],
      shipping_instruction: [
        :delivery_date, :delivery_time_slot, :special_note
      ],
      credit_card: [
        :number, :cvc, :exp_year, :exp_month, :name
      ]
    }

    def initialize(cart_id=nil)
      @redis = Redis.new(Cartbee.redis_conf)
      @key   = cart_id.nil? ? SecureRandom.hex : cart_id
      @data  = data
    end

    def data
      if @data
        @data
      else
        load_data(@redis.get(@key))
      end
    end

    # ------------------------------------------------------------
    # 保存されているItemsの情報を返却
    # ------------------------------------------------------------
    def items
      data[:items]
    end

    # ------------------------------------------------------------
    # カート内の商品の合計金額を計算する
    # ------------------------------------------------------------
    def total_cost
      data[:items].inject(0) do |res, (key, item)|
        res += item[:price].to_i * item[:quantity].to_i
        res
      end
    end

    # --------------------------------------------------
    # 指定された商品を追加する
    # --------------------------------------------------
    def add_item(item_info={})

      unless item_info.has_key?(:price)
        raise "Price needs to be passed when adding a item to cart."
      end

      unless item_info.has_key?(:quantity)
        raise "Quantity needs to be passed when adding a item to cart."
      end

      @data[:items][rand_key] = item_info

      dump_data
    end

    # --------------------------------------------------
    # 購入データを追加する
    # --------------------------------------------------
    def append_transaction_data(key, data)
      if send(key.to_s + '_validate', data)
        @data[key.to_sym] = data
        dump_data
      else
        false
      end
    end

    # --------------------------------------------------
    # 指定されたkeyにあるデータを削除する
    # --------------------------------------------------
    def remove_item(key)
      @data[:items].delete(key.to_sym)

      dump_data
    end

    # --------------------------------------------------
    # 指定されたkeyにあるデータのquantityを変更する
    # --------------------------------------------------
    def change_quantity_of key, quantity
      @data[:items][key][:quantity] = quantity

      dump_data
    end

    # --------------------------------------------------
    # Redisから削除
    # --------------------------------------------------
    def destroy
      @redis.del(@key)
    end

    private

    # ------------------------------------------------------------
    # Redis内から取ってきたデータをデシリアイズして返却。
    # またdataがnilの場合はdataのひな形を返却
    # ------------------------------------------------------------
    def load_data(data)
      if data.nil?
        {
          items: {},
          user_id: nil,
          shipping_address: {},
          billing_address: {},
          credit_card: {},
          shipping_instruction: {},
          created_at: Time.now.to_s,
          updated_at: Time.now.to_s
        }
      else
        symbolize(MessagePack.unpack(data))
      end
    end

    # ------------------------------------------------------------
    # Redis内のデータを書き換える
    # ------------------------------------------------------------
    def dump_data
      @data[:updated_at] = Time.now.to_s
      @redis.set(@key, @data.to_msgpack)
      @redis.expire(@key, Cartbee.expire_time)
    end

    # ------------------------------------------------------------
    # ランダムな文字列を生成
    # ------------------------------------------------------------
    def rand_key
      (0...8).map { (65 + rand(26)).chr }.join.to_sym
    end

    # ------------------------------------------------------------
    # HashのKeyをシンボルにして返却
    # ------------------------------------------------------------
    def symbolize hash
      hash.inject({}) do |res,(key, val)|
        res[key.to_sym] = val.is_a?(Hash) ? symbolize(val) : val
        res
      end
    end
  end
end
