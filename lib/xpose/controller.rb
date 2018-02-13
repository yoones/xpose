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
          decorate(inst.conf.method_name, args) if inst.conf.decorate
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
          _expose({ name: inst.decorated_name, value: -> { inst.call(self) }, decorate: false })
          # define_method inst.conf.method_name do
          #   if instance_variable_defined?(inst.conf.instance_variable_name)
          #     instance_variable_get(inst.conf.instance_variable_name)
          #   else
          #     instance_variable_set(inst.conf.instance_variable_name, inst.call(self))
          #   end
          # end
          # helper_method inst.conf.decorated_method_name
        end
      end

      def decorate(name, **args, &block)
        _decorate({ name: name }.merge(args))
      end

      # def decorate(name, **args)
      #   args = ::Xpose::DEFAULT_CONFIGURATION.merge(args)
      #   mname = :"decorated_#{name}"
      #   vname = :"@#{mname}"
      #   define_method mname do
      #     if instance_variable_defined?(vname)
      #       instance_variable_get(vname)
      #     else
      #       value = if decorator == :infer
      #                 send(name).decorate
      #               elsif decorator == Class
      #                 decorator.new(send(name))
      #               elsif decorator.respond_to?(:call)
      #                 decorator.call(send(name))
      #               elsif Symbol === decorator
      #                 decorator.to_s.singularize.capitalize.constantize
      #               else
      #                 raise StandardError.new('Unknown decorator')
      #               end
      #       instance_variable_set(vname, value)
      #     end
      #   end
      #   helper_method mname
      # end
    end
  end
end
