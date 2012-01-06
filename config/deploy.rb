set :rvm_ruby_string, '1.9.3'
set :application, "asndv"
set :user, "justvitalius"
set :serv, "178.162.126.190"
set :server_name, "estate.booq.pro"
set :assets, false

set :backup_db, false
set :backup_sys, false

set :repository,  "git@github.com:IvanShamatov/asndv.git"
set :branch, "master"
set :deploy_to, "/home/#{user}/www/#{application}"
set :deploy_via, :remote_cache

set :keep_releases, 5
set :use_sudo, false

set :scm, :git

role :app, serv
role :web, serv
role :db, serv, :primary => true
