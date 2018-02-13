module Xpose
  class Exposed
    attr_accessor :conf

    def initialize(**args)
      args = ::Xpose::DEFAULT_CONFIGURATION.merge(args).keep_if do |k, v|
        ::Xpose::DEFAULT_CONFIGURATION.has_key?(k)
      end
      @conf = ::Xpose::Configuration.build(args)
      conf.name.tap do |name|
        raise MissingParameterError if name.nil?
      end
    end

    def call(instance)
      @instance = instance
      v = if value.nil? && infer_value
            (conf.method_name.to_s == conf.pluralized_name ? :collection : :record)
          else
            value
          end
      reinterpret_value(v)
    end

    private

    def klass
      @klass ||= conf.singularized_name.capitalize.constantize
    end

    def reinterpret_value(v)
      if v.respond_to?(:call)
        instance.instance_exec &v
      elsif v == :collection
        infer_collection
      elsif v == :record
        infer_record
      else
        v
      end
    end

    def infer_collection
      klass.send(scope)
    end

    def infer_record
      source = if instance.respond_to?(conf.pluralized_name)
                 ->{ instance.send(conf.pluralized_name) }
               else
                 ->{ klass.send(scope) }
               end
      if instance.respond_to?(:params) && instance.params.has_key?(:id)
        source.call.find(instance.params[:id])
      else
        source.call.new(params)
      end
    end

    def params
      @params ||=
        if instance.respond_to?("#{conf.singularized_name}_params")
          instance.send("#{conf.singularized_name}_params")
        else
          {}
        end
    end
  end
end
