module Ethereum
  class Contract
    attr_accessor :resubmit_proxy

    def build
      class_name = @name.camelize
      parent = self
      create_function_proxies
      create_event_proxies
      class_methods = Class.new do
        extend Forwardable
        def_delegators :parent, :deploy_payload, :deploy_args, :call_payload, :call_args
        def_delegators :parent, :signed_deploy, :key, :key=
        def_delegators :parent, :gas_limit, :gas_price, :gas_limit=, :gas_price=, :nonce, :nonce=
        def_delegators :parent, :abi, :deployment, :events
        def_delegators :parent, :estimate, :deploy, :deploy_and_wait
        def_delegators :parent, :address, :address=, :sender, :sender=
        def_delegator :parent, :call_raw_proxy, :call_raw
        def_delegator :parent, :call_proxy, :call
        def_delegator :parent, :transact_proxy, :transact
        def_delegator :parent, :resubmit_proxy, :resubmit
        def_delegator :parent, :transact_and_wait_proxy, :transact_and_wait
        def_delegator :parent, :new_filter_proxy, :new_filter
        def_delegator :parent, :get_filter_logs_proxy, :get_filter_logs
        def_delegator :parent, :get_filter_change_proxy, :get_filter_changes
        define_method :parent do
          parent
        end
      end
      Ethereum::Contract.send(:remove_const, class_name) if Ethereum::Contract.const_defined?(class_name, false)
      Ethereum::Contract.const_set(class_name, class_methods)
      @class_object = class_methods
    end

    def resubmit_raw_transaction(payload, nonce, to = nil)
      Eth.configure { |c| c.chain_id = @client.net_version["result"].to_i }
      args = {
          from: key.address,
          value: 0,
          data: payload,
          nonce: nonce,
          gas_limit: gas_limit,
          gas_price: gas_price
      }
      args[:to] = to if to
      tx = Eth::Tx.new(args)
      tx.sign key
      @client.eth_send_raw_transaction(tx.hex)["result"]
    end

    def resubmit(fun, nonce, *args)
      if key
        tx = resubmit_raw_transaction(call_payload(fun, args), nonce, address)
      else
        tx = nil
      end

      return Ethereum::Transaction.new(tx, @client, call_payload(fun, args), args)
    end

    private

    def create_function_proxies
      parent = self
      call_raw_proxy, call_proxy, transact_proxy, transact_and_wait_proxy, resubmit_proxy = Class.new, Class.new, Class.new, Class.new, Class.new
      @functions.each do |fun|
        call_raw_proxy.send(:define_method, parent.function_name(fun)) { |*args| parent.call_raw(fun, *args) }
        call_proxy.send(:define_method, parent.function_name(fun)) { |*args| parent.call(fun, *args) }
        transact_proxy.send(:define_method, parent.function_name(fun)) { |*args| parent.transact(fun, *args) }
        resubmit_proxy.send(:define_method, parent.function_name(fun)) { |nonce, *args| parent.resubmit(fun, nonce, *args) }
        transact_and_wait_proxy.send(:define_method, parent.function_name(fun)) { |*args| parent.transact_and_wait(fun, *args) }
      end
      @call_raw_proxy, @call_proxy, @transact_proxy, @transact_and_wait_proxy, @resubmit_proxy =  call_raw_proxy.new, call_proxy.new, transact_proxy.new, transact_and_wait_proxy.new, resubmit_proxy.new
    end
  end
end
