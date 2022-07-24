require_relative "containers"

class CSVParser

  def initialize
    @file_name = "masterplan.csv"
    @rows = 36
    @cols = 15
  end

  def find_csv(file_name)
    File.exist?(file_name)
  end

  def get_total_lines(file_name)
    file = File.open(file_name)
    counter = 0
    file.each do |line|
      counter += 1
    end
    counter
  end

  def prettify_line(line)
    splitted_line = line.split(';')
    splitted_line.delete_at(0)

    if splitted_line.any?

      last_element = splitted_line[splitted_line.length - 1]

      if last_element == "\r\n"
        splitted_line[splitted_line.length - 1] = ""
      else
        end_of_last_element = last_element.length - 3
        splitted_line[splitted_line.length - 1] = last_element[0..end_of_last_element]
      end
    end

    splitted_line
  end

  def get_last_week
    file = File.open(@file_name)
    total_lines = get_total_lines(@file_name)
    file_counter = 0
    line_counter = 0

    week = WeekContainer.new

    file.each do |line|
      if file_counter >= total_lines - @rows + 1 and file_counter <= total_lines
        splitted_line = prettify_line(line)

        day_counter = 0
        i = 0

        until i >= splitted_line.length - 1 do

          week.days[day_counter].checks[line_counter] = splitted_line[i]
          week.days[day_counter].activities[line_counter] = splitted_line[i + 1]

          day_counter += 1
          i += 2
        end

        line_counter += 1
      end
      file_counter += 1
    end

    week
  end

end

