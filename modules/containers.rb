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
  attr_accessor :days, :timetables, :percentages, :total_percentage, :sentences

  def initialize
    @days = []
    @percentages = []
    @timetables = []
    @size = 7
    @total_percentage = 0
    @sentences = {
      bad: 'So why do you use the masterplan?',
      enough: 'You are a good planner, but you should start respecting these plans!',
      good: 'You could still improve!',
      very_good: 'You are the perfect planner!'
    }

    # initialize days size-1 times
    @size.times { |i| @days[i] = DayContainer.new }
  end

  def calc_days_percentage
    sum_percentages = 0

    @days.each do |day|
      n_checks = day.checks.count('V')
      n_activities = day.activities.count - day.activities.count('none')

      begin
        percentage = (100 * n_checks) / n_activities
      rescue ZeroDivisionError
        percentage = 0
      end

      @percentages.push(percentage)
      sum_percentages += percentage
    end

    @total_percentage = sum_percentages / 7
  end
end
