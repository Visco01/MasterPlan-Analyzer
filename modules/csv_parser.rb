#! /usr/bin/env ruby
# frozen_string_literal: true

require_relative 'containers'

# CSVParser class
class CSVParser
  def initialize
    @file_name = 'masterplan.csv'
    @rows = 37
    @cols = 15
  end

  def empty_line(week)
    7.times do |i|
      week.days[i].checks << 'X'
      week.days[i].activities << 'none'
    end
  end

  def update_content(body, week)
    day_counter = 0
    body.length.times do |i|
      week.days[day_counter].checks << body[i] if i.even?
      week.days[day_counter].activities << body[i] if i.odd?
      day_counter += 1 if i.odd?
    end
  end

  def fill_week(arr, week)
    arr.each_with_index do |line, i|
      next if i.zero?

      week.timetables << line[0]
      line.size == 1 ? empty_line(week) : update_content(line[1..], week)
    end
  end

  def last_week?
    begin
      # return the last 37 lines of the file
      file = `tail -n 37 masterplan.csv`.split(/\r\n/).map { |line| line.split(';') }
    rescue ENOENT
      puts "File #{@file_name} not found."
      exit(false)
    end
    week = WeekContainer.new
    fill_week(file, week)
    week.calc_days_percentage
    week
  end
end
