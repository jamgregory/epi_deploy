$: << File.expand_path('../../lib', __FILE__)

def run_ed(commands)
  run_simple "#{File.join(File.dirname(__FILE__), '../bin/ed')} #{commands}", false
end
