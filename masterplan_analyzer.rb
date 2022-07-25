require_relative "./modules/masterplan.rb"

def main
  plan = MasterPlan.new
  plan.load_last_week
  plan.print_last_week
end

main
