require_relative "csv_parser"

class MasterPlan
  def initialize
    @parser = CSVParser.new
    @weeks = []
    @max_weeks = 12
  end

  def load_last_week
    @weeks.push(@parser.get_last_week)
    puts "#{@weeks[0].days[6].activities}"
    puts "#{@weeks[0].days[6].checks}"
  end
end
