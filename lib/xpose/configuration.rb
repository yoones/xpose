module Xpose
  module Configuration
    DEFAULT_VALUES = {
      name: nil,
      value: nil,
      decorate: true,
      decorator: :infer,
      infer_value: true,
      scope: :all
    }.freeze

    def self.build(**args)
      args = DEFAULT_CONFIGURATION.merge(args).keep_if do |k, v|
        DEFAULT_CONFIGURATION.has_key?(k)
      end
      OpenStruct.new(args).tap do |conf|
        conf.name = conf.name.to_s
        conf.method_name = conf.name.to_sym
        conf.instance_variable_name = :"@#{conf.method_name}"
        conf.decorated_method_name = :"decorated_#{conf.name}"
        conf.decorated_instance_variable_name = :"@decorated_#{conf.method_name}"
        conf.singularized_name = name.singularize
        conf.pluralized_name = name.pluralize
      end
    end
  end
end
