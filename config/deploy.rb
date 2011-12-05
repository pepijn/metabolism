# Stel de applicatie in
set :application, 'metabolism'

require 'capistrano_colors'
$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
require 'rvm/capistrano'
require "bundler/capistrano"

set :user, 'deployer'
set :use_sudo, false

server 'plict.nl', :app, :web, :db, :primary => true

set :deploy_to, "/var/www/#{application}"
set :repository, "git@github.com:pepijn/#{application}.git"
set :scm, "git"
set :branch, "master"

namespace :deploy do
  desc "Restart application"
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end
end

namespace :log do
  desc "Tail the production log"
  task :default do
    run "tail -n 300 -f #{current_path}/log/production.log"
  end
end

require './config/boot'
