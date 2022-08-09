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
        out_directory: /report
        masterplan: /masterplan/masterplan.csv
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
  end

  private

  def bootstrap_config
    setup_settings_dir unless Dir.exist?(@settings_path)
    setup_settings_file unless File.exist?(@settings_path + @file_name)
    @current_settings = load_settings_file(@settings_path + @file_name)[0]
    update_bk
    settings_lamb_utility
  end

  def lamb_builder_file_system_operations(operation, command)
    case operation
    when 'write'
      lamb_operation = -> { YAML.safe_load(DEFAULT_SETTINGS, symbolize_names: true).to_yaml }
    when 'read'
      lamb_operation = ->(f) { YAML.load_stream(f, symbolize_names: true) }
    when 'open'
      lamb_operation = ->(p) { File.open(p, 'r') { |f| @lamb_hash[:yaml_read].call(f) } }
    when 'copy'
      lamb_operation = ->(x, y) { FileUtils.copy_file(x, y) }
    end
    @lamb_hash.store(command.to_sym, lamb_operation)
  end

  def lamb_builder_from_current_settings(command, *hash_values)
    case hash_values.count
    when 2
      get_settings = ->() { @current_settings[:settings][hash_values[0].to_sym][hash_values[1].to_sym]}
    when 3
      get_settings = ->(s) { @current_settings[:settings][hash_values[0].to_sym][hash_values[1].to_sym][s.downcase.to_sym]}
    end
    @lamb_hash.store(command.to_sym, get_settings)
  end

  def yaml_lamb_utility
    lamb_builder_file_system_operations('write', 'yaml_write')
    lamb_builder_file_system_operations('read', 'yaml_read')
    lamb_builder_file_system_operations('open', 'yaml_open')
    lamb_builder_file_system_operations('copy', 'yaml_copy')
    @lamb_hash.rehash
  end

  def settings_lamb_utility
    lamb_builder_from_current_settings('get_day', 'date', 'days', true)
    lamb_builder_from_current_settings('get_week', 'date', 'max_weeks')
    lamb_builder_from_current_settings('get_export_dir', 'paths', 'out_directory')
    lamb_builder_from_current_settings('get_masterplan', 'paths', 'masterplan')
    lamb_builder_from_current_settings('get_settings', 'paths', 'settings')
    lamb_builder_from_current_settings('get_sentence', 'customizations', 'sentences', true)
    lamb_builder_from_current_settings('get_tot_sentences', 'customizations', 'sentences')
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
