#! /usr/bin/env ruby
# frozen_string_literal: true

require_relative 'containers'
require_relative 'settings_manager'
require 'csv'

# CSVParser class
class CSVParser < SettingsManager
  CSV_TEMPLATE = <<~TEMPLATE
    ;;Monday;;Tuesday;;Wednesday;;Thursday;;Friday;;Saturday;;Sunday
    6.30;;;;;;;;;;;;;;
    7.00;;;;;;;;;;;;;;
    7.30;;;;;;;;;;;;;;
    8.00;;;;;;;;;;;;;;
    8.30;;;;;;;;;;;;;;
    9.00;;;;;;;;;;;;;;
    9.30;;;;;;;;;;;;;;
    10.00;;;;;;;;;;;;;;
    10.30;;;;;;;;;;;;;;
    11.00;;;;;;;;;;;;;;
    11.30;;;;;;;;;;;;;;
    12.00;;;;;;;;;;;;;;
    12.30;;;;;;;;;;;;;;
    13.00;;;;;;;;;;;;;;
    13.30;;;;;;;;;;;;;;
    14.00;;;;;;;;;;;;;;
    14.30;;;;;;;;;;;;;;
    15.00;;;;;;;;;;;;;;
    15.30;;;;;;;;;;;;;;
    16.00;;;;;;;;;;;;;;
    16.30;;;;;;;;;;;;;;
    17.00;;;;;;;;;;;;;;
    17.30;;;;;;;;;;;;;;
    18.00;;;;;;;;;;;;;;
    18.30;;;;;;;;;;;;;;
    19.00;;;;;;;;;;;;;;
    19.30;;;;;;;;;;;;;;
    20.00;;;;;;;;;;;;;;
    20.30;;;;;;;;;;;;;;
    21.00;;;;;;;;;;;;;;
    21.30;;;;;;;;;;;;;;
    22.00;;;;;;;;;;;;;;
    22.30;;;;;;;;;;;;;;
    23.00;;;;;;;;;;;;;;
    23.30;;;;;;;;;;;;;;
    00.00;;;;;;;;;;;;;;
  TEMPLATE

  def initialize
    super
    @csv_name = (Dir.pwd + @lamb_hash[:get_masterplan].call)
    bootstrap_csv

    @rows = 37
    @cols = 15
  end

  def setup_csv_dir
    FileUtils.mkdir_p(File.dirname(@csv_name))
  end

  def setup_csv_file
    File.write(@csv_name, CSV.parse(CSV_TEMPLATE, headers: true))
  end

  def bootstrap_csv
    setup_csv_dir
    setup_csv_file
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
      # return the last [@rows] lines of the file
      file = `tail -n #{@rows} #{@csv_name}`.split(/\r\n/).map { |line| line.split(';') }
    rescue Errno::ENOENT
      puts "File #{@csv_name} not found."
      exit(false)
    end
    week = WeekContainer.new(@lamb_hash[:get_tot_sentences].call)
    fill_week(file, week)
    week.calc_days_percentage
    week
  end
end
