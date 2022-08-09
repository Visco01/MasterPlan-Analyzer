#! /usr/bin/env ruby
# frozen_string_literal: true

require_relative 'settings_manager'
require_relative 'csv_parser'
require_relative 'containers'
require_relative 'html_template'
require 'test/unit/assertions'

# MasterPlan Class
class MasterPlan < SettingsManager
  include Test::Unit::Assertions

  def initialize
    super
    @parser = CSVParser.new
    @export_dir = (Dir.pwd + @lamb_hash[:get_export_dir].call)
    @weeks = []
    @days = %w[Monday Tuesday Wednesday Thursday Friday Saturday Sunday]
    @max_weeks = @lamb_hash[:get_week].call
    disable_days
  end

  def load_last_week
    @weeks << @parser.last_week?
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

  def disable_days
    @days.each do |day|
      @days.delete(day) unless @lamb_hash[:get_day].call(day)
    end
  end

  def print_activities(day)
    day.activities.length.times do |i|
      next if day.activities[i].empty?

      puts "\t#{week.timetables[i]}\t#{day.checks[i] != 'V' ? 'X' : 'V'}\t#{day.activities[i]}"
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

  def decide_status(percentage, sentences)
    case percentage
    when 75..100
      sentences[:very_good]
    when 50..74
      sentences[:good]
    when 25..49
      sentences[:enough]
    when 0..24
      sentences[:bad]
    when String
      p 'Hey, I can not accept a string'
    else
      p "#{percentage}! really? is this a real percentage!?"
    end
  end

  def get_final_sentence(week)
    "#{week.total_percentage}% of your tasks! #{decide_status(week.total_percentage, week.sentences)}"
  end

  def write_table(day, week)
    s = String.new
    day.activities.each_with_index do |activity, index|
      activity = '[No activity planned]' if activity.nil?
      s.concat "\t<tr>\n\t  <td class=\"text-left\">#{week.timetables.at(index)}</td>\n"
      s.concat "\t  <td class=\"text-left\">#{activity}</td>\n"
      s.concat "\t  <td class=\"text-center\">\n\t    <input class=\"form-check-input\" type=\"checkbox\" value=\"\""
      s.concat "#{day.checks.at(index) == 'V' ? 'checked' : ''} onclick=\"return false\">\n\t  </td>\n\t</tr>\n"
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
    footer = html_template.footer.clone&.gsub!(/completed/, "completed #{get_final_sentence(week)}")
    html_template.header + body + footer
  end

  def write_html_file(string)
    FileUtils.mkdir_p(@export_dir) unless Dir.exist?(@export_dir)
    File.open("#{@export_dir}/weekly_report.html", 'w') { |f| f.write string.to_s }
  end
end
