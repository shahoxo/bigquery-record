require 'active_support/hash_with_indifferent_access'
require 'bigquery-record/enum'

module BigQueryRecord
  class Base
    extend Enum
    attr_accessor :attributes

    def initialize(*args)
      @attributes = ActiveSupport::HashWithIndifferentAccess.new
      options = args.extract_options!
      options.each do |k, v|
        column = columns_hash[k.to_s]
        column ? @attributes[k] = column.cast(v) : @attributes[k] = v
      end
    end

    def [](key)
      return unless key
      @attributes[key.to_s]
    end

    def columns_hash
      self.class.columns_hash
    end

    class << self
      attr_accessor :abstract_class, :table_name, :columns, :schema_fetched

      def inherited(child)
        child.abstract_class = false
        child.table_name = child.name.underscore.remove("_log") # TODO: move default table name to config
        child.columns = []
        child.schema_fetched = false
        child.enum_attributes = []
      end

      def fetch_schema
        return if schema_fetched
        fetch_schema!
      end

      def fetch_schema!
        return if abstract_class
        raw_columns = Client.fetch_schema(table_name)
        self.columns = raw_columns.map{|column| Column.new(name: column['name'], raw_type: column['type'])}
        define_column_methods
        self.schema_fetched = true
      end

      def column_names
        columns.map(&:name)
      end

      def columns_hash
        columns.map{|column| [column.name, column]}.to_h
      end

      def define_column_methods
        columns.each do |column|
          define_method column.name do
            @attributes[column.name]
          end
        end
      end

      def all
        search.result
      end

      def search(condition = {})
        fetch_schema
        Search.new(klass: self, condition: condition, columns: { limit: :integer })
      end

      def default_limit
        100
      end
    end

    self.abstract_class = true
    self.table_name = ''
    self.schema_fetched = false
    self.columns = []
  end

end