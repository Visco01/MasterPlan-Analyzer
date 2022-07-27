class DayContainer
  attr_accessor :activities, :checks

  def initialize
    @activities = []
    @checks = []
    @size = 35
  end

end

class WeekContainer
  attr_accessor :days, :timetables, :percentages, :total_percentage

  def initialize
    @days = []
    @percentages = []
    @timetables = []
    @size = 7
    @total_percentage = 0

    for i in 0..@size - 1
      @days[i] = DayContainer.new
    end
  end

end
