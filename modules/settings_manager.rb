#! /usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'
require 'yaml'

# Class YamlManager interact with the yaml db
class SettingsManager
  attr_reader :dir_name, :file_name, :current_settings, :lamb_hash

  DEFAULT_SETTINGS = <<~PREFERENCES
    ---
    settings:
      date:
        days:
          monday: On
          tuesday: On
          wednesday: On
          thursday: On
          friday: On
          saturday: On
          sunday: On
        max_weeks: 12
      paths:
        out_report: /report
        masterplan: /masterplan
        settings: /settings/settings.yml
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
    @settings_path = "#{Dir.pwd}/#{@dir_name}/"
    @bk_file_name = '.backup_settings.yml'
    @lamb_hash = {}

    yaml_lamb_utility
    bootstrap_config

    # k = %w[mon tue wed thu fri sat sun]
    # s = %w[bad enough good very_good]

    # @lamb_hash = fill_hashs(k)
  end

  def bootstrap_config
    setup_settings_dir unless Dir.exist?(@settings_path)
    setup_settings_file unless File.exist?(@settings_path + @file_name)
    @current_settings = load_settings_file(@settings_path + @file_name)[0]
    update_bk
    settings_lamb_utility
  end

  def create_lamb_days
    l_get_mon = ->(m) { @current_settings[:settings][:date][:days][m.downcase.to_sym] }
    @lamb_hash.store(:get_day, l_get_mon)
  end

  def create_lamb_weeks
    l_get_weeks = -> { @current_settings[:settings][:date][:max_weeks] }
    @lamb_hash.store(:get_week, l_get_weeks)
  end

  def create_lamb_report
    l_get_report = -> { @current_settings[:settings][:paths][:out_report] }
    @lamb_hash.store(:get_report, l_get_report)
  end

  def create_lamb_masterplan
    l_get_masterplan = -> { @current_settings[:settings][:paths][:masterplan] }
    @lamb_hash.store(:get_masterplan, l_get_masterplan)
  end

  def create_lamb_settings
    l_get_settings = -> { @current_settings[:settings][:paths][:settings] }
    @lamb_hash.store(:get_settings, l_get_settings)
  end

  def create_lamb_sentence
    l_get_sentence = ->(s) { @current_settings[:settings][:customizations][:sentences][s.to_sym] }
    @lamb_hash.store(:get_sentence, l_get_sentence)
  end

  def create_lamb_tot_sentences
    l_get_total_sentences = -> { @current_settings[:settings][:customizations][:sentences] }
    @lamb_hash.store(:get_tot_sentences, l_get_total_sentences)
  end

  def create_lamb_yaml_write
    lamb_write = -> { YAML.safe_load(DEFAULT_SETTINGS, symbolize_names: true).to_yaml }
    @lamb_hash.store(:yaml_write, lamb_write)
  end

  def create_lamb_yaml_read
    lamb_read = ->(f) { YAML.load_stream(f, symbolize_names: true) }
    @lamb_hash.store(:yaml_read, lamb_read)
  end

  def create_lamb_yaml_open
    lamb_open = ->(p) { File.open(p, 'r') { |f| @lamb_hash[:yaml_read].call(f) } }
    @lamb_hash.store(:yaml_open, lamb_open)
  end

  def create_lamb_yaml_copy
    lamb_copy = ->(x, y) { FileUtils.copy_file(x, y) }
    @lamb_hash.store(:yaml_copy, lamb_copy)
  end

  def yaml_lamb_utility
    create_lamb_yaml_write
    create_lamb_yaml_read
    create_lamb_yaml_open
    create_lamb_yaml_copy
  end

  def settings_lamb_utility
    create_lamb_days
    create_lamb_weeks
    create_lamb_report
    create_lamb_masterplan
    create_lamb_settings
    create_lamb_sentence
    create_lamb_tot_sentences
    @lamb_hash.rehash
  end

  def setup_settings_dir
    FileUtils.mkdir_p(@dir_name)
  end

  def setup_settings_file
    File.write(@settings_path + @file_name, @lamb_hash[:yaml_write].call)
    # Copy Default Template in BK file
    @lamb_hash[:yaml_copy].call(@settings_path + @file_name, @settings_path + @bk_file_name)
  end

  def update_bk
    @lamb_hash[:yaml_copy].call(@settings_path + @file_name, @settings_path + @bk_file_name)
  end

  def load_settings_file(file_path)
    @lamb_hash[:yaml_open].call(file_path)
  rescue Psych::SyntaxError
    p 'Error Reading the settings, restoring from last BK'
    restore_settings
    @lamb_hash[:yaml_open].call(@settings_path + @bk_file_name)
  end

  def restore_settings
    # Copy BK file to settings file
    @lamb_hash[:yaml_copy].call(@settings_path + @bk_file_name, @settings_path + @file_name)
  end

  def reset_settings
    # Copy TEMPLATE to settings file
    File.write(@settings_path + @file_name, @lamb_hash[:yaml_write].call)
  end
end
