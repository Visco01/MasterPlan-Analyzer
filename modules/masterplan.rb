#! /usr/bin/env ruby
# frozen_string_literal: true

require_relative 'csv_parser'
require_relative 'html_template'
require 'test/unit/assertions'
# require 'enumerator'

# MasterPlan Class
class MasterPlan
  include Test::Unit::Assertions

  def initialize
    @parser = CSVParser.new
    @weeks = []
    @days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
    @max_weeks = 12
  end

  def load_last_week
    @weeks.push(@parser.get_last_week)
  end

  def print_last_week
    week = @weeks[0]
    calc_days_percentage(week)
    day_counter = 0

    puts '\n           Weekly Report\n\n'
    puts '----------------------------------------'
    week.days.each do |day|
      puts "              #{@days[day_counter]}\n\n"
      puts 'TIMETABLES     DONE          TASK\n'

      for i in 0..day.activities.length
        # next iteration if condition true!
        next if day.activities[i].instance_of? (String) && !day.activities[i].empty?

          day.checks[i] != 'V' ? check = 'X' : check = 'V';
          puts "   #{week.timetables[i]}         #{check}          #{day.activities[i]}"
      end

      puts "\nTASKS COMPLETED THIS DAY: #{week.percentages[day_counter]}%"

      puts '----------------------------------------'
      day_counter += 1
    end

    puts "\nTASKS COMPLETED THIS WEEK: #{week.total_percentage}%"
  end

  def calc_days_percentage(week)
    sum_percentages = 0

    week.days.each do |day|
      n_checks = day.checks.count('V')
      null_activities = day.activities.count('')
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

  def weekly_report_export_to_html
    week = @weeks[0]

    begin
      assert(!week.nil?, 'weekly_report_export_to_html: week object is nil. firstly you need to call load method')
    rescue Test::Unit::AssertionFailedError => e
      puts e.message.to_s
      exit(false)
    end

    html_string = weekly_report_export_to_html_aux(week)

    write_html_file(html_string)
  end

  private

  def weekly_report_export_to_html_aux(week)
    html_template = HTMLTemplate.new

    html_body = html_template.body.split('\n')

    counter = tr_position = 0
    html_body.each do |line|
      line = line.strip

      if line == '</tr>'
        tr_position = counter + 1
      end

      counter += 1
    end

    first_chunk = second_chunk = ''
    html_body.each_slice(tr_position) do |slice|
      if first_chunk.empty?
        first_chunk = slice
      else
        second_chunk = slice
      end
    end

    first_chunk_template = first_chunk.clone
    result_chunk = []
    day_counter = 0

    week.days.each do |day|
      first_chunk = first_chunk_template.clone

      begin
        first_chunk[1]['Monday'] = @days[day_counter]
      rescue IndexError
        first_chunk[1][@days[day_counter - 1]] = @days[day_counter]
      end

      day.activities.each do |activity|
        first_chunk.push('<tr>')
        first_chunk.push('<td>')
        first_chunk.push(week.timetables[0])
        first_chunk.push('</td>')
        first_chunk.push('<td>')
        first_chunk.push(activity)
        first_chunk.push('</td>')
        first_chunk.push('<td>')
        first_chunk.push(day.checks[5])
        first_chunk.push('</td>')
        first_chunk.push('</tr>')
      end

      puts first_chunk[1].to_s
      day_counter += 1
      result_chunk += first_chunk
    end

    html_body = result_chunk.concat(second_chunk)
    html_body = html_body.join('\n')

    html_result_string = html_template.header + html_body + html_template.footer
    html_result_string
  end

  def write_html_file(string)
    File.open('outputs/weekly_report.html', 'w') { |f| f.write string.to_s }
  end
end
