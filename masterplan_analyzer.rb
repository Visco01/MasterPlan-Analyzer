#! /usr/bin/env ruby
# frozen_string_literal: true

require_relative './modules/masterplan'
require_relative './modules/html_template'

def main
  plan = MasterPlan.new
  plan.load_last_week
  plan.weekly_report_export_to_html
  # plan.print_last_week
end

main
