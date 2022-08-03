#! /usr/bin/env ruby
# frozen_string_literal: true

# HTMLTemplate class
class HTMLTemplate
  attr_accessor :header, :body, :footer

  def initialize
    body_data = header_data = footer_data = ''

    begin
      header_data = File.open('./resources/header_template.html')
      body_data = File.open('./resources/body_template.html')
      footer_data = File.open('./resources/footer_template.html')
    rescue
      puts 'File not found!!'
      exit(false)
    end

    begin
      @header = header_data.read
      @body = body_data.read
      @footer = footer_data.read
    rescue NoMethodError
      puts 'Unknown error while reading html templates...'
    end
  end
end
