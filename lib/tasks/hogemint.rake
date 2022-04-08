namespace :hogemint do
  namespace :release do
    desc "Run scripts to set up production for release."
    task :run do |_task_name, _args|
      puts "Migrating the database..."
      Rake::Task["db:migrate"].invoke
    end
  end
end
