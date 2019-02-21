class TwocheckoutController < ApplicationController

  def checkout
  end

  def proceed_to_pay
    @link_generator = TwocheckoutDynamicLinkGenerator.new(
      name: params[:name],
      merchant: params[:merchant],
      dynamic: params[:dynamic],
      currency: params[:currency],
      return_url: params[:return_url],
      return_type: params[:return_type],
      tpl: params[:tpl],
      prod: params[:prod],
      tangible: params[:tangible],
      price: params[:price],
      type: params[:type],
      qty: params[:qty],
      test: params[:test],
      order_ext_ref: params[:order_ext_ref]
    )

    redirect_to @link_generator.dynamic_buy_link, allow_other_host: true
  end

  def order_processed
  end

end
