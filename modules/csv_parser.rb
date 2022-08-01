require_relative "containers"

class CSVParser

  def initialize
    @file_name = "masterplan.csv"
    @rows = 37
    @cols = 15
  end

  def get_total_lines
    begin
      file = File.open(@file_name)
    rescue
      puts "File #{@file_name} not found."
      exit(false)
    end

    counter = 0
    file.each do |line|
      counter += 1
    end

    counter
  end

  def prettify_line(line)
    line.force_encoding('utf-8')
    splitted_line = line.split(';')

    if splitted_line.any? and splitted_line[0] != splitted_line[-1]

      last_element = splitted_line[-1]

      if last_element == "\r\n"
        splitted_line[-1] = ""
      else
        splitted_line[-1] = last_element[0..-3]
      end
    end

    splitted_line
  end

  def get_last_week
    begin
      file = File.open(@file_name)
    rescue
      puts "File #{@file_name} not found."
      exit(false)
    end

    total_lines = get_total_lines
    file_counter = 0
    line_counter = 0

    week = WeekContainer.new

    file.each do |line|

      if file_counter >= total_lines - @rows + 1 and file_counter <= total_lines

        splitted_line = prettify_line(line)

        day_counter = 0
        i = 0

        if splitted_line.length > 1

          until i >= splitted_line.length - 1 do

            week.timetables[line_counter] = splitted_line[0]
            week.days[day_counter].checks[line_counter] = splitted_line[i + 1]
            week.days[day_counter].activities[line_counter] = splitted_line[i + 2]

            day_counter += 1
            i += 2
          end

        else
          week.timetables[line_counter] = splitted_line[0]
        end

        if week.timetables[line_counter].length == 4
          week.timetables[line_counter] += " "
        end

        line_counter += 1
      end
      file_counter += 1
    end

    week
  end

end
