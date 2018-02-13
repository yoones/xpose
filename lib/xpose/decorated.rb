module Xpose
  class Decorated
    attr_accessor :conf

    def initialize(**args)
      @conf = ::Xpose::Configuration.build(args)
      raise MissingParameter if conf.name.nil?
    end

    def call(instance)
      v = instance.send(conf.method_name)
      if conf.decorator == :infer
        infer(v)
      elsif Class === conf.decorator
        decorator.new(v)
      elsif decorator.respond_to?(:call)
        decorator.call(v)
      elsif Symbol === decorator
        decorator.to_s.singularize.capitalize.constantize.new(v)
      else
        raise StandardError.new('Unknown decorator')
      end
    end

    private

    def infer(v)
      if v.respond_to?(:decorate)
        v.decorate
      elsif class_exists?(klass)
        klass.new(v)
      else
        raise UnknownDecoratorError
      end
    end

    def klass
      @klass ||= "#{conf.singularized_name.capitalize}Decorator".constantize
    end

    def class_exists?(class_name)
      Module.const_get(class_name).is_a?(Class)
    rescue NameError
      return false
    end
  end
end
