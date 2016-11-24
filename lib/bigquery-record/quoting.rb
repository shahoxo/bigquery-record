module BigQueryRecord
  module Quoting
    # Quotes a string, escaping any ' (single quote) and \ (backslash) characters.
    # https://github.com/rails/rails/blob/28ec8c4a57197a43e4369bfbdfa92625bd592fe0/activerecord/lib/active_record/connection_adapters/abstract/quoting.rb#L79-L81
    def quote_string(s)
      s.gsub('\\'.freeze, '\&\&'.freeze).gsub("'".freeze, "''".freeze) # ' (for ruby-mode)
    end

    def quote(value)
      case value
      when String then quote_string(value)
      else value
      end
    end
  end
end
