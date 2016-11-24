require 'active_support/hash_with_indifferent_access'
require 'bigquery-record/quoting'

module BigQueryRecord
  class Search
    include Quoting
    class ClientError < StandardError; end

    attr_reader :klass
    delegate :columns, :column_names, :model_name, to: :klass

    def initialize(klass:, condition:, columns: {})
      @klass, @condition, @custom_columns = klass, ActiveSupport::HashWithIndifferentAccess.new(condition), columns.stringify_keys
      @order_condition = ActiveSupport::HashWithIndifferentAccess.new(@condition.delete(:order))
      @limit_condition = @condition.delete(:limit)
      @select_condition = @condition.delete(:select) || '*'
      @group_condition = @condition.delete(:group) || []
      @having_condition = ActiveSupport::HashWithIndifferentAccess.new(@condition.delete(:having))
    end

    def formatted_where
      format_condition(@condition)
    end

    def formatted_having
      format_condition(@having_condition)
    end

    # FROM TABLE_DATE_RANGE(test.action, TIMESTAMP("2016-06-02"), TIMESTAMP("2016-06-09"))
    def formatted_from
      time_from = (@condition[:time_from] || 7.days.ago).to_date.to_s
      time_to = (@condition[:time_to] || Date.today).to_date.to_s
      "TABLE_DATE_RANGE(#{Client.dataset}.#{@klass.table_name}, TIMESTAMP('#{time_from}'), TIMESTAMP('#{time_to}'))"
    end

    def search_field?(field_name)
      column_names.include?(field_name) || column_with_suffix?(field_name) || @custom_columns.keys.include?(field_name)
    end

    def column_with_suffix?(field_name)
      self.class.suffixes.map do |suffix|
        field_name.end_with?(suffix) && (column_names + @custom_columns.keys).include?(field_name.remove(suffix))
      end.inject(&:|)
    end

    def query
      QueryBuilder.new(
        select: @select_condition,
        from: formatted_from,
        where: formatted_where,
        group: @group_condition,
        having: formatted_having,
        order: @order_condition,
        limit: @limit_condition
      ).build
    end

    alias to_sql query

    def result
      self.class.logger.debug("Send query to BigQuery sql: #{query}")
      Client.sql(query).map{|raw_value| @klass.new(raw_value)}
    rescue => e
      raise ClientError.new("#{e.class}: #{e.message}")
    end

    def method_missing(action, *args)
      if search_field? action.to_s
        @condition.merge(@having_condition)[action]
      else
        super
      end
    end

    def current_column_state(column_name)
      @condition.merge(@having_condition).find{|k, v| k.start_with?(column_name.to_s)}
    end

    private

    def format_condition(condition)
      condition.map do |k, v|
        column =
          if custom_column_type = @custom_columns.find{|name, type| k.start_with?(name)}.try(:last)
            Column.new(type: custom_column_type)
          else
            columns.find{|c| k.to_s == c.name} || columns.find{|c| k.to_s.start_with?(c.name)}
          end
        column ? [k, column.to_sql(v)] : [k, quote(v)]
      end.to_h
    end

    class << self
      attr_writer :logger

      def suffixes
        QueryBuilder.builders.map(&:suffix)
      end

      def logger
        @logger ||= Logger.new(STDOUT)
      end
    end
  end

end