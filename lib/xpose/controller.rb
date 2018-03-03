module Xpose
  module Controller
    extend ActiveSupport::Concern

    module ClassMethods
      def _expose(**args)
        ::Xpose::Exposed.new(args).tap do |inst|
          @@exposed ||= {}
          @@exposed[inst.conf.name] = inst
          define_method inst.conf.name do
            if instance_variable_defined?(inst.conf.ivar_name)
              instance_variable_get(inst.conf.ivar_name)
            else
              instance_variable_set(inst.conf.ivar_name, inst.exposed_value(self))
            end
          end
          helper_method(inst.conf.name)
        end
      end

      def expose(names, value = nil, **args, &block)
        value = value || args.fetch(:value, nil) || block
        [names].flatten.each { |name| _expose({ name: name, value: value }.merge(args)) }
      end

      def expose!(names, value = nil, **args, &block)
        expose(name, value, args, &block)
        [names].flatten.each { |name| before_action(name) }
      end

      def exposed
        @@exposed ||= {}
      end
    end
  end
end
