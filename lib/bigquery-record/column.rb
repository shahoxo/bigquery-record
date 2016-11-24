require 'bigquery-record/quoting'

module BigQueryRecord
  class Column
    include Quoting
    attr_reader :name, :raw_type, :type

    def initialize(name: nil, raw_type: nil, type: nil)
      @name, @raw_type, @type = name, raw_type, type
    end

    # depend on BigQuery
    def cast(value)
      case type
      when :time; Time.at(value.to_f)
      when :integer; value.to_i if value
      when :string; value.to_s
      when :boolean; value
      else value
      end
    rescue
      value
    end

    def to_sql(value)
      _value = quote(value)
      case type
      when :time; "\"#{_value.to_time.utc.to_s(:db)}\""
      when :integer; _value.to_i
      when :string; '"' + _value.to_s + '"'
      when :boolean; _value
      else _value
      end
    rescue
      _value
    end

    def to_csv(value)
      value.to_s
    end

    def type
      @type ||=
        case raw_type.upcase
        when 'TIMESTAMP'; :time
        when 'INTEGER'; :integer
        when 'STRING'; :string
        when 'BOOLEAN'; :boolean
        else :string
        end
    end
  end
end
