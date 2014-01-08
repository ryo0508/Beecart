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

  private

  def get_current_cart
    @current_cart = current_cart
  end
end
