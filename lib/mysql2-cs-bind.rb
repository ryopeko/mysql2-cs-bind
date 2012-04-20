require 'mysql2'

class Mysql2::Client

  def xquery(sql, *args)
    options = if args.size > 0 and args[-1].is_a?(Hash)
                args.pop
              else
                {}
              end
    if args.size < 1
      query(sql, options)
    else
      query(pseudo_bind(sql, args.flatten), options)
    end
  end

  private
  def pseudo_bind(sql, values)
    sql = sql.dup

    placeholders = []
    search_pos = 0
    while pos = sql.index('?', search_pos)
      placeholders.push(pos)
      search_pos = pos + 1
    end
    raise ArgumentError, "mismatch between placeholders number and values arguments" if placeholders.length != values.length

    while pos = placeholders.pop()
      rawvalue = values.pop()
      if rawvalue.nil?
        sql[pos] = 'NULL'
      elsif rawvalue.is_a?(Time)
        sql[pos] = "'" + rawvalue.strftime('%Y-%m-%d %H:%M:%S') + "'"
      else
        sql[pos] = "'" + Mysql2::Client.escape(rawvalue.to_s) + "'"
      end
    end
    sql
  end

end