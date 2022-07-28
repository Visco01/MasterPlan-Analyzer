require_relative "./modules/masterplan.rb"

def main
  plan = MasterPlan.new
  plan.load_last_week
  plan.print_last_week
 
  # begin
  #   file = File.open("./resources/template.html")
  #   file.each do |line|
  #     puts "#{line}"
  #   end
  # rescue
  #   puts "File not found."
  #   exit(false)
  # end
end

main
