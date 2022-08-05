#! /usr/bin/env ruby
# frozen_string_literal: true

require_relative 'csv_parser'
require_relative 'containers'
require_relative 'html_template'
require 'test/unit/assertions'

# MasterPlan Class
class MasterPlan
  include Test::Unit::Assertions

  def initialize
    @parser = CSVParser.new
    @weeks = []
    @days = %w[Monday Tuesday Wednesday Thursday Friday Saturday Sunday]
    @max_weeks = 12
  end

  def load_last_week
    @weeks << @parser.get_last_week
  end

  def print_activities(day)
    day.activities.length.times do |i|
      next if day.activities[i].empty?

      puts "   #{week.timetables[i]}         #{day.checks[i] != 'V' ? 'X' : 'V'}          #{day.activities[i]}"
    end
  end

  def print_table(week)
    week.days.each_with_index do |day, iter|
      puts "              #{@days[iter]}\n\n"
      puts "TIMETABLES     DONE          TASK\n"
      print_activities(day)
      puts "\nTASKS COMPLETED THIS DAY: #{week.percentages[iter]}%"
      puts '----------------------------------------'
    end
  end

  def print_last_week
    week = @weeks[0]
    week.calc_days_percentage
    puts "\n           Weekly Report\n\n"
    puts '----------------------------------------'
    print_table(week.days)
    puts "\nTASKS COMPLETED THIS WEEK: #{week.total_percentage}%"
  end

  def weekly_report_export_to_html
    week = @weeks[0]
    begin
      assert(!week.nil?, 'weekly_report_export_to_html: week object is nil. firstly you need to call load method')
    rescue Test::Unit::AssertionFailedError => e
      puts e.message.to_s
      exit(false)
    end
    write_html_file(weekly_report_export_to_html_aux(week))
  end

  private

  def write_table(day, week)
    s = String.new
    day.activities.each_with_index do |activity, index|
      activity = '[No activity planned]' if activity.empty?
      s.concat "<tr>\n<td class=\"text-left\">#{week.timetables.at(index)}</td>"
      s.concat "<td class=\"text-left\">#{activity}</td>"
      s.concat "<td class=\"text-center\">\n<input class=\"form-check-input\" type=\"checkbox\" value=\"\" "
      s.concat "#{day.checks.at(index) == 'V' ? 'checked' : ''} onclick=\"return false\" >\n</td></tr>"
    end
    s
  end

  def set_day(body, week, day, iter)
    body&.gsub!(/>\s\w+</, "> #{@days.at(iter)}<")
    body&.gsub!(/sec-./, "sec-#{iter + 1}")
    body&.gsub!(/>\d</, ">#{iter + 1}<")
    body&.gsub!(/completed:/, "completed: #{week.percentages.at(iter)}%")
    body&.gsub!(%r{</tr>}, "</tr>\n #{write_table(day, week)}")
  end

  def update_html(week, body)
    result = []
    week.days.each_with_index do |day, i|
      tmp = body.clone
      set_day(tmp, week, day, i)
      result << tmp
    end
    result
  end

  def weekly_report_export_to_html_aux(week)
    html_template = HTMLTemplate.new
    body = update_html(week, html_template.body).join("\n")
    footer = html_template.footer.clone&.gsub!(/completed/, "completed #{week.total_percentage}%")
    html_template.header + body + footer
  end

  def write_html_file(string)
    File.open('outputs/weekly_report.html', 'w') { |f| f.write string.to_s }
  end
end
