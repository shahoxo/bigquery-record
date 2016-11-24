require 'active_support'
require 'active_support/core_ext'

module BigQueryRecord
  class QueryBuilder
    class Base
      def initialize(key:, value:)
        @key, @value = key.to_s, value
      end

      def to_sql
        ''
      end

      alias to_s to_sql

      def key_name
        @key.remove(suffix)
      end

      def suffix
        self.class.suffix
      end

      class << self
        attr_accessor :suffix
        def inherited(child)
          child.suffix= "_#{child.name.demodulize.underscore}"
        end
      end
    end

    class From < Base
      def to_sql
        "#{key_name} >= #{@value}"
      end
    end

    class To < Base
      def to_sql
        "#{key_name} <= #{@value}"
      end
    end

    class Eq < Base
      def to_sql
        "#{key_name} = #{@value}"
      end
    end

    class Gt < Base
      def to_sql
        "#{key_name} > #{@value}"
      end
    end

    class Lt < Base
      def to_sql
        "#{key_name} < #{@value}"
      end
    end

    cattr_accessor :builders
    @@builders = [From, To, Eq, Gt, Lt]

    def initialize(select: '*', from:, where: {}, group: [], having: {}, order: {}, limit: nil)
      @select, @from, @where, @group, @having, @order, @limit = select, from, where, group, having, order, limit
    end

    def find_builder(key)
      suffix = key.to_s.slice(/_[^_]*$/)
      self.class.builders_hash[suffix] || Eq
    end

    def build
      _sql = "#{select_sql} #{from_sql}"
      _sql += " #{where_sql}" if where_sql.present?
      _sql += " #{group_sql}" if group_sql.present?
      _sql += " #{having_sql}" if having_sql.present?
      _sql += " #{order_sql}" if order_sql.present?
      _sql += " #{limit_sql}" if limit_sql.present?
      _sql
    end

    def limit_sql
      return '' unless @limit
      "LIMIT #{@limit}"
    end

    def order_sql
      return '' if @order.empty?
      'ORDER BY ' + @order.inject('') do |merged_sql, (k, v)|
        sql = "#{k} #{v}"
        merged_sql.empty? ? merged_sql = sql : merged_sql += ", #{sql}"
        merged_sql
      end
    end

    def group_sql
      return '' if @group.empty?
      'GROUP BY ' + @group.join(', ')
    end

    def having_sql
      return '' if @having.empty?
      'HAVING ' + @having.inject('') do |merged_sql, (k, v)|
        sql = find_builder(k).new(key: k, value: v).to_sql
        merged_sql.empty? ? merged_sql = sql : merged_sql += " AND #{sql}"
        merged_sql
      end
    end

    def where_sql
      return '' if @where.empty?
      'WHERE ' + @where.inject('') do |merged_sql, (k, v)|
        sql = find_builder(k).new(key: k, value: v).to_sql
        merged_sql.empty? ? merged_sql = sql : merged_sql += " AND #{sql}"
        merged_sql
      end
    end

    def select_sql
      _selected_columns = @select.is_a?(Array) ? @select.join(', ') : @select
      "SELECT #{_selected_columns}"
    end

    def from_sql
      "FROM #{@from}"
    end

    class << self
      def builders_hash
        builders.map {|builder| [builder.suffix, builder]}.to_h
      end
    end
  end

end
