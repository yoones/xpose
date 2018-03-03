module Xpose
  class Configuration

    DEFAULT_VALUES = {
      name: nil,
      value: nil,
      decorate: true,
      decorator: :infer,
      scope: :all
      # source: :infer (:infer, :method, : .call : ...)
    }.freeze

    def initialize(**options)
      @options = options
      permit_options! unless options.fetch(:permissive, false)
      build_config
      build_internal_defaults
    end

    def method_missing(method, *args, &block)
      config.send(method, *args, &block)
    end

    def model
      config.singularized_name.capitalize.constantize
    end

    private

    attr_accessor :config

    def permit_options!
      (@options.keys - DEFAULT_VALUES.keys).tap do |unknown_keys|
        raise UnknownOptionsError.new(unknown_keys) unless unknown_keys.empty?
      end
    end

    def build_config
      @config = OpenStruct.new(DEFAULT_VALUES.merge(@options)).tap do |c|
        raise MissingOptionsError.new(:name) if c.name.blank?

        c.name = c.name.to_sym
        c.ivar_name = :"@#{c.name}"
        c.singularized_name = c.name.to_s.singularize
        c.pluralized_name = c.singularized_name.pluralize
      end
    end
  end
end
