module Xpose
  class Decorated
    attr_reader :conf

    def initialize(**options)
      @conf = ::Xpose::Configuration.new(options.merge(permissive: true))
    end

    def value(instance, v)
      return v unless shall_decorate?(instance, v)
      if conf.decorator == :infer
        infer(v)
      elsif Class === conf.decorator
        conf.decorator.new(v)
      elsif conf.decorator.respond_to?(:call)
        conf.decorator.call(v)
      elsif Symbol === conf.decorator && class_exists?(klass_from_symbol)
        klass_from_symbol.new(v)
      else
        raise UnknownDecoratorError.new(conf.decorator)
      end
    end

    private

    def shall_decorate?(instance, v)
      return conf.decorate if [true, false].include?(conf.decorate)
      raise UnknownOptionsError.new(:decorate) unless conf.decorate.respond_to?(:call)
      instance.instance_exec &conf.decorate
    end

    def infer(v)
      if v.respond_to?(:decorate)
        v.decorate
      elsif class_exists?(klass_from_model)
        klass_from_model.new(v)
      else
        raise UnknownDecoratorError.new(conf.decorator)
      end
    end

    def klass_from_symbol
      conf.decorator.to_s.singularize.capitalize.constantize
    end

    def klass_from_model
      "#{conf.model}Decorator".constantize
    end

    def class_exists?(class_name)
      Module.const_get(class_name.to_s).is_a?(Class)
    rescue NameError
      return false
    end
  end
end
