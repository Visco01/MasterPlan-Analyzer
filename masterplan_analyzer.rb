require_relative "./modules/masterplan.rb"
require_relative "./modules/html_template.rb"
def main
  plan = MasterPlan.new
  plan.load_last_week
  #plan.print_last_week
end

main
