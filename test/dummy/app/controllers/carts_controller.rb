class CartsController < ApplicationController

  before_action :get_current_cart

  def index
    respond_to do |format|
      format.html
    end
  end

  def add_item
    @current_cart.add_item({
      quantity: params[:items][:quantity],
      price:    params[:items][:price],
    })

    respond_to do |format|
      format.html { redirect_to root_path }
    end
  end

  def remove_item
    @current_cart.remove_item params[:items][:key]

    respond_to do |format|
      format.html { redirect_to root_path }
    end
  end

  def destroy
    @current_cart.destroy

    respond_to do |format|
      format.html { redirect_to root_path }
    end
  end

  def charge
    current_cart.charge({
      card: {
        :number    => 4012888888881881,
        :exp_month => 11,
        :exp_year  => 2014,
        :cvc       => 123,
        :name      => "KEI KUBO"
      }
    })
  end

  def examine
    current_cart.examine({
      card: {
        :number    => 4012888888881881,
        :exp_month => 11,
        :exp_year  => 2014,
        :cvc       => 123,
        :name      => "KEI KUBO"
      }
    })

    # render :text => 'OK'
    redirect_to :index
  end

  def edit_item
    current_cart.update_item(params[:item_key], {
      quantity: params[:quantity]
    })

    redirect_to :index
  end

  def append_info
    result = current_cart.append_info(params[:key], params[:key], params[:append_data])

    if result.valid
      redirect_to root_path
    else
      render text: result.errors[:messages].join("<br />")
    end
  end

  private

  def get_current_cart
    @current_cart = current_cart
  end
end
