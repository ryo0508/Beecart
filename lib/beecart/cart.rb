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

  class Cart

    attr_reader :key

    def initialize(cart_id=nil)
      @redis = Redis.new(Beecart.config.redis)

      if !cart_id.nil? & @redis.get(cart_id).nil?
        raise Error, "Cart was not found with the given cart_id"
      end

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


    # 任意のキーを持ったアイテムを返却する
    #
    # @return [Hashie::Mash] アイテム
    def item(key)
      data[:items][key] = data

      return Hashie::Mash.new(item_key: key).merge(data)
    end

    # カート内のitemsを返却
    #
    # @return [Array]
    def items
      items = []

      data[:items].each do |key, data|
        items << Hashie::Mash.new(item_key: key.to_s).merge(data)
      end

      return items
    end

    # カート内の商品の合計金額を計算する
    #
    # @param  [Boolean] with_tax 商品税を入れるかどうか
    # @return [Integer] 税抜き合計金額
    def total_price(with_tax=false)
      price = data[:items].inject(0) do |res, (key, item)|
        res += item[:price].to_i * item[:quantity].to_i
        res.to_i
      end

      return with_tax ? price + ( price * Beecart.config.tax_rate ).to_i : price
    end

    # カート内の商品の合計金額にかかる消費税を計算
    #
    # @return [Integer] 合計金額にかかる消費税
    def tax
      return ( total_price * Beecart.config.tax_rate ).to_i
    end

    # カート内の商品の税込み合計金額を計算する
    #
    # @return [Integer] 税込み合計金額
    # def total_price_with_tax
    #   data[:items].inject(0) do |res, (key, item)|
    #     res += item[:price].to_i * item[:quantity].to_i * Beecart.config.tax_rate
    #     res.ceil.to_i
    #   end
    # end

    # 指定された商品を追加する
    #
    # @param [Hash] item_info 追加する商品の情報
    # @option item_info [Integer] :price 商品の値段
    # @option item_info [Integer] :quantity 購入希望個数
    def add_item(item_info={ })

      unless item_info.has_key?(:price)
        raise Error,"Price needs to be passed when adding a item to cart."
      end

      unless item_info.has_key?(:quantity)
        raise Error, "Quantity needs to be passed when adding a item to cart."
      end

      random_key_for_item = rand_key
      @data[:items][random_key_for_item] = item_info

      dump_data

      return random_key_for_item
    end

    # 購入データを追加する
    #
    # @param  [Symbol] key 追加するデータの識別子
    # @param  [Symbol] validator_name Validator名
    # @param  [Hash] data 追加するデータ
    # @return [Data] 追加されたデータ
    def append_info(key, validator_name=false, data)

      validator = get_validator(validator_name)
      validator.run(data)

      unless validator.error
        @data[key.to_sym] = data
        dump_data
      end

      validator
    end

    # 入っている商品に変更を加える
    #
    # @param [String] key
    # @param [Hash]   changes 変更されるもののキーとバリュー
    # @return [Boolean]
    def update_item(key, changes={})

      target_item = @data[:items][key.to_sym]

      unless target_item.nil?
        changes.each do |label, value|
          target_item[label.to_sym] = value
        end

        dump_data
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
    #
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

    private

    def get_validator validator_name
      begin
        validator = ["Beecart", "Validators", "#{ validator_name.to_s }_validator".camelize].join('::').constantize.new

        p "--------------------------------------------------"
        p "Get Validator"
        p "Validator => #{ validator }"
        p "Validator => #{ validator }"
        p "--------------------------------------------------"
      rescue NameError
        p "--------------------------------------------------"
        p "Get Validator: Failed"
        p "--------------------------------------------------"
        validator = Beecart::Validators::BaseValidator.new
      end

      validator
    end

    # Redis内から取ってきたデータをデシリアイズして返却。
    # またdataがnilの場合はdataのひな形を返却
    #
    # @param [Hash, nil]
    def load_data(data)
      if data.nil?
        {
          items: {},
          user_id: nil,
          created_at: Time.now.to_s,
          updated_at: Time.now.to_s
        }.merge(Beecart.config.default_cart_info)
      else
        symbolize(MessagePack.unpack(data))
      end
    end

    # Redis内のデータを書き換える
    def dump_data
      @data[:updated_at] = Time.now.to_s
      @redis.set(@key, @data.to_msgpack, { ex: Beecart.config.expire_time })
      # @redis.expire(@key, Beecart.config.expire_time)
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
