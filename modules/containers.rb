#! /usr/bin/env ruby
# frozen_string_literal: true

# Day container
class DayContainer
  attr_accessor :activities, :checks

  def initialize
    @activities = []
    @checks = []
    @size = 35
  end
end

# Week container
class WeekContainer
  attr_accessor :days, :timetables, :percentages, :total_percentage

  def initialize
    @days = []
    @percentages = []
    @timetables = []
    @size = 7
    @total_percentage = 0

    # initialize days size-1 times
    @size.times { |i| @days[i] = DayContainer.new }
  end
end
