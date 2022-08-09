#! /usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'
require 'yaml'

# Class YamlManager interact with the yaml db
class SettingsManager
  attr_reader :dir_name, :file_name

  DEFAULT_SETTINGS = <<~PREFERENCES
    ---
    settings:
      date:
        days:
          mon: On
          tue: On
          wed: On
          thu: On
          fri: On
          sat: On
          sun: On
        max_weeks: 12
      paths:
        out_report: /report
        preferences: /settings/settings.yml
      customizations:
        sentences:
          bad: 'So why do you use the masterplan?'
          enough: 'You are a good planner, but you should start respecting these plans!'
          good: 'You could still improve!'
          very_good: 'You are the perfect planner!'
  PREFERENCES

  def initialize
    @dir_name = 'settings'
    @file_name = 'settings.yml'
    @backup_file_name = '.backup_settings.yml'
    @current_settings = []

    setup_settings_dir
    setup_settings_file
  end

  def setup_settings_dir
    FileUtils.mkdir_p(@dir_name) unless Dir.exist?(@dir_name)
  end

  def setup_settings_file
    lamb_write = -> { YAML.safe_load(DEFAULT_SETTINGS, symbolize_names: true).to_yaml }
    File.write("./#{@dir_name}/#{@file_name}", lamb_write.call) unless File.exist?("./#{@dir_name}/#{@file_name}")

    begin
      File.open("./#{@dir_name}/#{@file_name}", 'r') { |f| @current_settings = YAML.load_stream(f, symbolize_names: true)}
      write_settings_file("./#{@dir_name}/#{@backup_file_name}", @current_settings)
    rescue Psych::SyntaxError
      p "SyntaxError in settings file (/#{@dir_name}/#{@file_name})"
      reset_settings
      p 'Settings restored to last working configuration.'
      exit(1)
    end
  end

  def write_settings_file(file_path, content)
    File.open(file_path, 'w') { |f| f.write(content.to_yaml) }
  end

  def reset_settings
    last_working_settings = []
    begin
      File.open("./#{@dir_name}/#{@backup_file_name}", 'r') { |f| last_working_settings = YAML.load_stream(f, symbolize_names: true).to_yaml}
    rescue Psych::SyntaxError
      last_working_settings = DEFAULT_SETTINGS
    end

    File.open("./#{@dir_name}/#{@file_name}", 'w') { |f| f.write(last_working_settings) }
  end
end
