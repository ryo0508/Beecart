# -*- coding: utf-8 -*-

module Beecart

  # カートに入れた商品をRedisサーバー上に保存させるためのラッパー
  #
  #
  # 商品情報以外に
  # - 顧客情報
  #   - 送り先住所
  #   - 受取先住所
  #   - カード情報
  # - カート作成日時
  # - カート更新日時
  # などの情報も保存することが可能。
  #
  # @!attribute [rw] data
  #   @return [Hash] redisとのコネクションを持ったオブジェクト
  #
  # @!attribute [r] redis
  #   @return [Object] redisとのコネクションを持ったオブジェクト
  #
  # @!attribute [r] key
  #   @return [String] カートを識別するためのランダムな文字列

  class ShoppingCart

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

    attr_reader :key

    def initialize(cart_id=nil)
      @redis = Redis.new(Beecart.config.redis)
      @key   = cart_id.nil? ? SecureRandom.hex : cart_id
      @data  = data
    end

    # 保存されているデーターをredisから取り出す。
    #
    # @return [Hash]
    def data
      if @data
        @data
      else
        load_data(@redis.get(@key))
      end
    end

    # カート内のitemsを返却
    # @return [Hash]
    def items
      data[:items]
    end

    # カート内の商品の合計金額を計算する
    #
    # @return [Integer]
    def total_cost
      data[:items].inject(0) do |res, (key, item)|
        res += item[:price].to_i * item[:quantity].to_i
        res
      end
    end

    # 指定された商品を追加する
    #
    # @param [Hash] item_info 追加する商品の情報
    # @option item_info [Integer] :price 商品の値段
    # @option item_info [Integer] :quantity (0) 購入希望個数
    def add_item(item_info={ quantity: 0})

      unless item_info.has_key?(:price)
        raise "Price needs to be passed when adding a item to cart."
      end

      unless item_info.has_key?(:quantity)
        raise "Quantity needs to be passed when adding a item to cart."
      end

      @data[:items][rand_key] = item_info

      dump_data
    end

    # 購入データを追加する
    #
    # @param [String] key 追加するデータの識別子
    # @param [Hash] data 追加するデータ
    # @return [Boolean]
    def append_info(key, data)
      if send(key.to_s + '_validate', data)
        @data[key.to_sym] = data
        dump_data
      else
        false
      end
    end

    # 指定されたkeyのアイテムを削除する
    #
    # @param [String] key 削除するアイテムのレコード
    def remove_item(key)
      @data[:items].delete(key.to_sym)

      dump_data
    end

    # 指定されたkeyにあるデータのquantityを変更する
    # @param [String] key
    # @param [Integer] quantity
    # @return [Boolean]
    def change_quantity_of key, quantity
      @data[:items][key][:quantity] = quantity

      dump_data
    end

    # Redisから削除
    def destroy
      @redis.del(@key)
    end

    # 仮計上(与信)をとる

    # 本計上を取る

    private

    # Redis内から取ってきたデータをデシリアイズして返却。
    # またdataがnilの場合はdataのひな形を返却
    #
    # @param [Hash, nil]
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

    # Redis内のデータを書き換える
    def dump_data
      @data[:updated_at] = Time.now.to_s
      @redis.set(@key, @data.to_msgpack)
      @redis.expire(@key, Beecart.expire_time)
    end

    # ランダムな文字列を生成
    def rand_key
      (0...8).map { (65 + rand(26)).chr }.join.to_sym
    end

    # HashのKeyをシンボルにして返却
    # @return シンボルにされたHash
    def symbolize hash
      hash.inject({}) do |res,(key, val)|
        res[key.to_sym] = val.is_a?(Hash) ? symbolize(val) : val
        res
      end
    end
  end
end
