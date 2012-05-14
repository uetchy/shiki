#!/usr/bin/env rake
require "bundler/gem_tasks"

desc "Run RSpec test"
task :test do
  `rspec -c spec/valid_test_rspec.rb`
end

desc "Pulling repository from master"
task :update do
  `git pull origin master`
end