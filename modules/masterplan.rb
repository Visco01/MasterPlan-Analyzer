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
    calc_days_percentage(week)
    day_counter = 0

    puts "\n           Weekly Report\n\n"
    puts "----------------------------------------"
    week.days.each do |day|
      puts "              #{@days[day_counter]}\n\n"
      puts "TIMETABLES     DONE          TASK\n"

      for i in 0..day.activities.length
        if day.activities[i].instance_of? String and not day.activities[i].empty?

          if day.checks[i] != "V"
            check = "X"
          else
            check = "V"
          end

          puts "   #{week.timetables[i]}         #{check}          #{day.activities[i]}"
        end
      end

      puts "\nTASKS COMPLETED THIS DAY: #{week.percentages[day_counter]}%"

      puts "----------------------------------------"
      day_counter += 1
    end

    puts "\nTASKS COMPLETED THIS WEEK: #{week.total_percentage}%"
  end

  def calc_days_percentage(week)
    sum_percentages = 0

    week.days.each do |day|

      n_checks = day.checks.count('V')
      null_activities = day.activities.count("")
      total_activities = day.activities.count
      n_activities = total_activities - null_activities

      begin
        percentage = (100 * n_checks) / n_activities
      rescue ZeroDivisionError
        percentage = 0
      end

      week.percentages.push(percentage)
      sum_percentages += percentage
    end

    week.total_percentage = sum_percentages / 7
  end

end
