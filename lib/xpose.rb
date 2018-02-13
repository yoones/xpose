require "xpose/version"
require "active_support/all"

module Xpose
  class MissingParameterError < StandardError ; end
  class UnknownDecoratorError < StandardError ; end

  autoload :Configuration, 'xpose/configuration.rb'
  autoload :Exposed, 'xpose/exposed.rb'
  autoload :Decorated, 'xpose/decorated.rb'
  autoload :Controller, 'xpose/controller.rb'

  ActiveSupport.on_load :action_controller do
    include Controller
  end
end
