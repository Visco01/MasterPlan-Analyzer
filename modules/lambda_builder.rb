#! /usr/bin/env ruby
# frozen_string_literal: true

class LambdaBuilder

  def self.yaml_lamb_utility(dest)
    lamb_builder_file_system_operations('write', 'yaml_write', dest)
    lamb_builder_file_system_operations('read', 'yaml_read', dest)
    lamb_builder_file_system_operations('open', 'yaml_open', dest)
    lamb_builder_file_system_operations('copy', 'yaml_copy', dest)
    dest.rehash
  end

  def self.settings_lamb_utility(source, dest)
    lamb_builder_from_current_settings('get_day', source, dest, 'date', 'days', true)
    lamb_builder_from_current_settings('get_week', source, dest, 'date', 'max_weeks')
    lamb_builder_from_current_settings('get_export_dir', source, dest, 'paths', 'out_directory')
    lamb_builder_from_current_settings('get_masterplan', source, dest, 'paths', 'masterplan')
    lamb_builder_from_current_settings('get_settings', source, dest, 'paths', 'settings')
    lamb_builder_from_current_settings('get_sentence', source, dest, 'customizations', 'sentences', true)
    lamb_builder_from_current_settings('get_tot_sentences', source, dest, 'customizations', 'sentences')
    dest.rehash
  end

  private

  def self.lamb_builder_file_system_operations(operation, command, dest)
    case operation
    when 'write'
      lamb_operation = -> { YAML.safe_load(Templates.get_default_settings, symbolize_names: true).to_yaml }
    when 'read'
      lamb_operation = ->(f) { YAML.load_stream(f, symbolize_names: true) }
    when 'open'
      lamb_operation = ->(p) { File.open(p, 'r') { |f| dest[:yaml_read].call(f) } }
    when 'copy'
      lamb_operation = ->(x, y) { FileUtils.copy_file(x, y) }
    end
    dest.store(command.to_sym, lamb_operation)
  end

  def self.lamb_builder_from_current_settings(command, source, dest, *hash_values)
    case hash_values.count
    when 2
      get_settings = ->() { source[:settings][hash_values[0].to_sym][hash_values[1].to_sym]}
    when 3
      get_settings = ->(s) { source[:settings][hash_values[0].to_sym][hash_values[1].to_sym][s.downcase.to_sym]}
    end
    dest.store(command.to_sym, get_settings)
  end

end
