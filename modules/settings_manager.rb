#! /usr/bin/env ruby
# frozen_string_literal: true

require_relative 'templates.rb'
require_relative 'lambda_builder.rb'
require 'fileutils'
require 'yaml'

# Class YamlManager interact with the yaml db
class SettingsManager
  attr_reader :dir_name, :file_name, :current_settings, :lamb_hash

  def initialize
    @dir_name = 'settings'
    @file_name = 'settings.yml'
    @settings_path = "#{Dir.pwd}/#{@dir_name}/"
    @bk_file_name = '.backup_settings.yml'
    @lamb_hash = {}

    bootstrap_config
  end

  private

  def bootstrap_config
    LambdaBuilder.yaml_lamb_utility(@lamb_hash)
    setup_settings_dir unless Dir.exist?(@settings_path)
    setup_settings_file unless File.exist?(@settings_path + @file_name)
    @current_settings = load_settings_file(@settings_path + @file_name)[0]
    update_bk
    LambdaBuilder.settings_lamb_utility(@current_settings, @lamb_hash)
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
