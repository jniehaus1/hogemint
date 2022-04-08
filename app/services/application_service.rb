#
# Mixin Concern to include with Allowance.ly Services such that a service can be called like so...
#
# module ServiceNamespace
#   class ServiceClass
#     include ApplicationService
#     def initialize(args = {}); end
#     def call; end
#   end
# end
#
# @example in one line, with no params
#   ServiceNamespace::ServiceClass.call
#
# @example in one line, with params
#   ServiceNamespace::ServiceClass.call(arg1: :foo, arg2: :bar)
#
# @example using the initializer and call separately, with no params
#   service = ServiceNamespace::ServiceClass.new
#   service.call
#   ServiceNamespace::ServiceClass.new.call # or in one line
#
# @example using the initializer and call separately, with params
#   service = ServiceNamespace::ServiceClass.new(arg1: :foo, arg2: :bar)
#   service.call
#   ServiceNamespace::ServiceClass.new(arg1: :foo, arg2: :bar).call # or in one line
#
module ApplicationService
  extend ActiveSupport::Concern

  class_methods do
    # Shortcut for having to call `ServiceName.new(args).call`
    # instead just call `ServiceName.call(args)`
    # @param [Object, Array<Object>, Hash{Symbol => Object>}] args
    # @raise [ServiceError]
    def call(*args)
      new(*args).call
    end
  end
end
