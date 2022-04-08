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
        { :order_id         => "CGORDER_#{@item.id}",
          :price_amount     => 0.75,
          :price_currency   => 'ETH',
          :receive_currency => 'ETH',
          :callback_url     => ENV["COINGATE_CALLBACK_URL"],
          :success_url      => success_url,
          :cancel_url       => root_url
        }
      end

      def success_url
        if @item.is_a?(Item)
          item_url(@item.id)
        elsif @item.is_a?(BaseItem)
          base_item_url(@item.id)
        else
          nil
        end
      end
    end
  end
end
