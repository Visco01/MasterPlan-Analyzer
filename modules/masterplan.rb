require_relative "csv_parser"

class MasterPlan
  def initialize
    @parser = CSVParser.new
    @weeks = []
    @days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    @max_weeks = 12
  end

  def load_last_week
    @weeks.push(@parser.get_last_week)
  end

  def print_last_week
    week = @weeks[0]
    day_counter = 0

    puts "Weekly Report\n\n"
    puts "---------------------------"
    week.days.each do |day|
      puts "          #{@days[day_counter]}\n\n"
      puts "    DONE          TASK\n"

      for i in 0..day.activities.length
        if day.activities[i].instance_of? String and not day.activities[i].empty?

          if day.checks[i] != "V"
            check = "X"
          else
            check = "V"
          end

          puts "     #{check}          #{day.activities[i]}"
        end
      end

      puts "---------------------------"
      day_counter += 1
    end
  end

end
