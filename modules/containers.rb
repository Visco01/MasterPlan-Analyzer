class DayContainer
  attr_accessor :activities, :checks

  def initialize
    @activities = []
    @checks = []
    @size = 35
  end

end

class WeekContainer
  attr_accessor :days

  def initialize
    @days = []
    @size = 7

    for i in 0..@size - 1
      @days[i] = DayContainer.new
    end
  end

end
