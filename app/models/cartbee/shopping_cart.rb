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
      @redis = Redis.new($appconf['redis'])
      @key   = cart_id.nil? ? SecureRandom.hex : cart_id
      @data  = data
    end

    def data
      @data || load_data(@redis.get(@key))
    end

    def get_products
      Product
        .find(data[:products].map{|key, p| p[:product_id]}.uniq)
        .inject({}){|res, p| res[p.id] = p; res;}
    end

    def get_features
      Feature
        .find(data[:products].map{|key, p| p[:feature_id]}.uniq)
        .inject({}){|res, f| res[f.id] = f; res;}
    end

    # ------------------------------------------------------------
    # 何度もDBにアクセスしないように最初にProductとFeatureをメモリに保存
    # それから返却するデータを形成する。
    # ------------------------------------------------------------
    def products
      products = get_products
      features = get_features

      data[:products].inject({}) do |res, (key,product)|
        res[key] = {
          product:  products[product[:product_id]],
          feature:  features[product[:feature_id]],
          quantity: product[:quantity],
          options:  product[:options]
        }
        res
      end
    end

    # ------------------------------------------------------------
    # カート内の商品の合計金額を計算する
    # ------------------------------------------------------------
    def total_cost
      products = Product.find(
        data[:products].map{|key, p| p[:product_id]}.uniq
      ).inject({}){|res, p| res[p.id] = p; res;}

      data[:products].inject(0) do |res, (key, p)|
        res += products[p[:product_id]].price * p[:quantity]
        res
      end
    end

    # --------------------------------------------------
    # 指定された商品を追加する
    # --------------------------------------------------
    def add_product(feature, number=1, options=[])

      product = feature.product

      @data[:products][rand_key] = {
        product_id: product.id,
        feature_id: feature.id,
        quantity:   number,
        options:    options
      }

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
    def remove_product(key)
      @data[:products].delete(key.to_sym)

      dump_data
    end

    # --------------------------------------------------
    # 指定されたkeyにあるデータのquantityを変更する
    # --------------------------------------------------
    def change_quantity_at_to key, quantity
      @data[:products][key][:quantity] = quantity
      dump_data
    end

    # --------------------------------------------------
    # Redisから削除
    # --------------------------------------------------
    def destroy
      @redis.del(@key)
    end

    private

    def shipping_address_validate data
      ShoppingCart::ShippingColumns[:shipping_address].each do |key|
        return false unless data.has_key?(key) && !data[key].blank?
        case key
        when :zip
        when :tel
        end
      end
    end

    def billing_address_validate data

      Rails.logger.debug "billing_address called"

      ShoppingCart::ShippingColumns[:billing_address].each do |key|
        return false unless data.has_key?(key) && !data[key].blank?
        case key
        when :zip
        end
      end
    end

    def shipping_instruction_validate data
      ShoppingCart::ShippingColumns[:shipping_instruction].each do |key|
        return false unless data.has_key?(key) && !data[key].blank?

        case key
        when :delivery_time_slot
        when :special_note
        end
      end
    end

    def credit_card_validate data
      ShoppingCart::ShippingColumns[:credit_card].each do |key|
        return false unless data.has_key?(key) && !data[key].blank?
        case key
        when :credit_card_number
        when :cvc
        when :expiration_month
        when :expiration_year
        end
      end
    end

    # ------------------------------------------------------------
    # Redis内から取ってきたデータをデシリアイズして返却。
    # またdataがnilの場合はdataのひな形を返却
    # ------------------------------------------------------------
    def load_data(data)
      if data.nil?
        {
          products: {},
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
      hash.inject({}){|res,(key, val)| res[key.to_sym] = val.is_a?(Hash) ? symbolize(val) : val; res;}
    end
  end
end
