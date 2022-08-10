#! /usr/bin/env ruby
# frozen_string_literal: true

# Templates class stores csv and settings templates
class Templates

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

  CSV_TEMPLATE = <<~TEMPLATE
    ;;Monday;;Tuesday;;Wednesday;;Thursday;;Friday;;Saturday;;Sunday
    6.30;;;;;;;;;;;;;;
    7.00;;;;;;;;;;;;;;
    7.30;;;;;;;;;;;;;;
    8.00;;;;;;;;;;;;;;
    8.30;;;;;;;;;;;;;;
    9.00;;;;;;;;;;;;;;
    9.30;;;;;;;;;;;;;;
    10.00;;;;;;;;;;;;;;
    10.30;;;;;;;;;;;;;;
    11.00;;;;;;;;;;;;;;
    11.30;;;;;;;;;;;;;;
    12.00;;;;;;;;;;;;;;
    12.30;;;;;;;;;;;;;;
    13.00;;;;;;;;;;;;;;
    13.30;;;;;;;;;;;;;;
    14.00;;;;;;;;;;;;;;
    14.30;;;;;;;;;;;;;;
    15.00;;;;;;;;;;;;;;
    15.30;;;;;;;;;;;;;;
    16.00;;;;;;;;;;;;;;
    16.30;;;;;;;;;;;;;;
    17.00;;;;;;;;;;;;;;
    17.30;;;;;;;;;;;;;;
    18.00;;;;;;;;;;;;;;
    18.30;;;;;;;;;;;;;;
    19.00;;;;;;;;;;;;;;
    19.30;;;;;;;;;;;;;;
    20.00;;;;;;;;;;;;;;
    20.30;;;;;;;;;;;;;;
    21.00;;;;;;;;;;;;;;
    21.30;;;;;;;;;;;;;;
    22.00;;;;;;;;;;;;;;
    22.30;;;;;;;;;;;;;;
    23.00;;;;;;;;;;;;;;
    23.30;;;;;;;;;;;;;;
    00.00;;;;;;;;;;;;;;
  TEMPLATE

  def self.get_default_settings
    DEFAULT_SETTINGS
  end

  def self.get_csv_template
    CSV_TEMPLATE
  end
end
