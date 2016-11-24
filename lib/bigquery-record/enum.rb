module BigQueryRecord
  module Enum
    def enum(options)
      enum_name = options.keys.first
      enum_hash = options.values.first
      attr = Attribute.new(self, enum_name, enum_hash)
      attr.define_enum_methods
      enum_name
    end

    def self.extended(obj)
      unless obj.singleton_class.method_defined?(:enum_attributes)
        obj.singleton_class.send(:attr_accessor, :enum_attributes)
        obj.enum_attributes = []
      end
    end

    class Attribute
      def initialize(klass, name, hash, suffix = :name)
        @klass, @name, @hash, @suffix = klass, name, hash, suffix
      end

      def define_enum_methods
        @klass.class_eval <<-EOS
          def #{humanized_method_name}
            #{@hash}.key(#{@name})
          end

          def #{i18n_humanized_method_name}
            #{i18n_hash}.key(#{@name})
          end

          class << self
            def #{@name.to_s.pluralize}
              #{@hash}
            end

            def #{@name.to_s.pluralize}_local
              #{i18n_hash}
            end
          end
        EOS

        unless @klass.method_defined?(@name)
          @klass.send(:attr_accessor, @name)
        end

        @klass.enum_attributes << @name
      end

      def humanized_method_name
        "#{@name}_#{@suffix}"
      end

      def i18n_humanized_method_name
        "#{@name}_local_#{@suffix}"
      end

      def i18n_hash
        if self.class.const_defined?(:I18n) && (translation_hash = I18n.t("enums.#{@name}")).is_a?(Hash)
          translation_hash.invert.map{|k, v| [k, @hash[v]]}.to_h
        else
          @hash
        end
      end
    end
  end
end
