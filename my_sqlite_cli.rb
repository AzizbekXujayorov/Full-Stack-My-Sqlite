require 'csv'

class MySqliteRequest
  def initialize
    @query_parts = {}
  end

  def select(columns)
    @query_parts['select'] = columns
    self
  end

  def from_table(table_name)
    @query_parts['from'] = table_name
    self
  end

  def where(column, value)
    @query_parts['where'] = { column => value }
    self
  end

  def insert(table_name)
    @query_parts['insert_into'] = table_name
    self
  end

  def update(table_name)
    @query_parts['update'] = table_name
    self
  end

  def delete
    @query_parts['delete'] = true
    self
  end

  def values(values)
    @query_parts['values'] = values
    self
  end

  def run
    # Here, you would implement actual database interaction.
    puts "Running query: #{@query_parts}"
  end
end

def main_func(p1)
  request = MySqliteRequest.new
  if p1.include?('VALUES')
    string_value = p1.split('VALUES')[1].strip
  end
  p1 = p1.split
  data_name = ""
  i = 0
  while i < p1.length
    case p1[i]
    when 'SELECT'
      columns = p1[i + 1].include?(',') ? p1[i + 1].split(',') : p1[i + 1]
      request = request.select(columns)
    when 'FROM'
      request = request.from_table(p1[i + 1])
    when 'WHERE'
      tmp = p1.join(' ').split('WHERE')[-1].split('=').map(&:strip)
      request = request.where(tmp[0], tmp[1].strip("'"))
    when 'INSERT'
      if p1[i + 1] == 'INTO'
        i += 2
        data_name = p1[i]
        request = request.insert(p1[i])
      end
    when 'UPDATE'
      request = request.update(p1[i + 1])
    when 'DELETE'
      request = request.delete
    when 'VALUES'
      i += 1
      File.open(data_name) do |f|
        contents = f.read.strip + "\n" + string_value.tr('()', '')
        hash_name = [CSV.new(contents).read(headers: true).map(&:to_h)].flatten
        request = request.values(hash_name[0])
      end
    when 'SET'
      i += 1
      temp = ""
      while i < p1.length && p1[i] != 'WHERE'
        temp += p1[i] + ' '
        i += 1
      end
      i -= 1
      hash_vals = {}
      temp.strip.split(',').each do |part|
        key, value = part.split('=')
        hash_vals[key.strip] = value.strip.strip("'")
      end
      request = request.values(hash_vals)
    end
    i += 1
  end
  request.run
end

puts "my_sqlite_cli>"
loop do
  print "my_sqlite_cli>"
  line = gets.chomp
  break if line.strip == 'quit'
  main_func(line.strip)
end
