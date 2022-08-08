#! /usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'
require 'yaml'

# Class YamlManager interact with the yaml db
class SettingsManager
  attr_reader :dir_name, :file_name

  DEFAULT_PREFERENCES = <<~PREFERENCES
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
    @dir_name = 'preferences'
    @file_name = 'settings.yml'
    setup_dir
    setup_file
    load_settings
  end

  def setup_dir
    FileUtils.mkdir_p(@dir_name) unless Dir.exist?(@dir_name)
  end

  def setup_file
    lamb_write = -> { YAML.safe_load(DEFAULT_PREFERENCES, symbolize_names: true).to_yaml }
    File.write("./#{@dir_name}/#{@file_name}", lamb_write.call) unless File.exist?("./#{@dir_name}/#{@file_name}")
  end

  def load_settings
    docs = []
    begin
      File.open("./#{@dir_name}/#{@file_name}", 'r') { |f| docs = YAML.load_stream(f, symbolize_names: true) }
    rescue Psych::SyntaxError
      p 'Hey buddy, SyntaxError in settings file (/preferences/settings.yml)'
      reset_settings
      p 'You are lucky, already fixed!! XD'
      exit(1)
    end
    docs
  end

  def reset_settings
    lamb_write = -> { YAML.safe_load(DEFAULT_PREFERENCES, symbolize_names: true).to_yaml }
    File.open("./#{@dir_name}/#{@file_name}", 'w') { |f| f.write(lamb_write.call) }
  end
end
