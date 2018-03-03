module Xpose
  class Exposed
    attr_accessor :conf

    def initialize(**args)
      @conf = ::Xpose::Configuration.new(args)
    end

    def value(instance)
      @instance = instance
      @value ||= interpret_value
    end

    def decorated_value(instance)
      @instance = instance
      @decorated_value ||=
        if value(instance) && conf.decorate
          ::Xpose::Decorated.new(conf.to_h).value(instance, value(instance))
        else
          nil
        end
    end

    def exposed_value(instance)
      decorated_value(instance) || value(instance)
    end

    private

    attr_reader :instance

    def interpret_value
      if conf.value.respond_to?(:call)
        instance.instance_exec &conf.value
      else
        infer_value
      end
    end

    def infer_value
      conf.value == :collection ? infer_collection : infer_record
    end

    def infer_collection
      conf.model.send(conf.scope)
    end

    def record_source
      if instance.respond_to?(conf.pluralized_name)
        instance.class.exposed[conf.pluralized_name.to_sym].value(instance)
      else
        conf.model.send(conf.scope)
      end
    end

    def infer_record
      if instance.respond_to?(:params, true) && instance.params.has_key?(:id)
        record_source.find(instance.params[:id])
      else
        record_source.new(params)
      end
    end

    def params
      return {} unless instance.respond_to?(:params)
      [
        "#{instance.params[:action]}_#{conf.singularized_name}_params",
        "#{conf.singularized_name}_params"
      ].each do |m|
        return instance.send(m) if instance.respond_to?(m, true)
      end
      {}
    end

    def class_exists?(class_name)
      Module.const_get(class_name).is_a?(Class)
    rescue NameError
      return false
    end
  end
end
