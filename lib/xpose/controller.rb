module Xpose
  module Controller
    extend ActiveSupport::Concern

    module ClassMethods
      def _expose(**args)
        ::Xpose::Exposed.new(args).tap do |inst|
          define_method inst.conf.method_name do
            if instance_variable_defined?(inst.conf.instance_variable_name)
              instance_variable_get(inst.conf.instance_variable_name)
            else
              instance_variable_set(inst.conf.instance_variable_name, inst.call(self))
            end
          end
          helper_method(inst.conf.method_name)
          self._decorate(args) if inst.conf[:decorate]
        end
      end

      def expose(name, value = nil, **args, &block)
        value = value || args.fetch(:value, nil) || block
        _expose({ name: name, value: value }.merge(args))
      end

      def expose!(name, value = nil, **args, &block)
        expose(name, value, args, &block)
        before_action(name)
      end

      def _decorate(**args)
        ::Xpose::Decorated.new(args).tap do |inst|
          _expose({ name: inst.conf.decorated_name, value: -> { inst.call(self) }, decorate: false })
        end
      end

      def decorate(name, **args, &block)
        _decorate({ name: name }.merge(args))
      end
    end
  end
end
