require 'bundler/gem_tasks'

desc 'Starts a "Pry" session with ExactTargetRest loaded'
task :console do
  require 'pry'
  require 'exact_target_rest'
  ARGV.clear
  include ExactTargetRest
  Pry.start
end

