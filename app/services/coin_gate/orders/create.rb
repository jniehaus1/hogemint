# Note - CoinGate::Merchant is the gem
module CoinGate
  module Orders
    class Create
      include ApplicationService
      include Rails.application.routes.url_helpers

      def initialize(item:)
        @item = item
      end

      # https://developer.coingate.com/docs/create-order
      def call
        CoinGate::Merchant::Order.create(post_params)
      end

      private

      def post_params
        { :order_id         => 'ORDER_1234871',
          :price_amount     => 0.75,
          :price_currency   => 'ETH',
          :receive_currency => 'ETH',
          :callback_url     => coingate_callback_url,
          :success_url      => base_item_url(@item.id),
          :cancel_url       => root_url
        }
      end
    end
  end
end
