load 'deploy' if respond_to?(:namespace) # cap2 differentiator

# Uncomment if you are using Rails' asset pipeline
# load 'deploy/assets'

Dir['vendor/gems/*/recipes/*.rb','vendor/plugins/*/recipes/*.rb'].each { |plugin| load(plugin) }


load 'config/deploy' # remove this line to skip loading any of the default tasks

#load 'deploy/assets'

$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
require "rvm/capistrano"
rvmrc = "rvm use #{rvm_ruby_string}"
set :rvm_type, :user

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

set :rails_env, "production"
config = YAML::load(File.open("config/database.yml"))
adapter = config[rails_env]["adapter"]
database = config[rails_env]["database"]
db_username = config[rails_env]["username"]
db_password = config[rails_env]["password"]



set :local_folder_path, "tmp/backup"
set :timestamp, Time.new.to_i.to_s
namespace :backup do
  desc "Backup a database"
  task :db do
    
    file_name = "#{database}-#{timestamp}.sql"
    archive_ext = "7z"
    dump_file_path = "#{shared_path}/backup/#{file_name}"
    output_file = "#{dump_file_path}.#{archive_ext}"


    require 'yaml'
    run "mkdir -p #{shared_path}/backup"

    
    if adapter == "postgresql"
      run "pg_dump -U #{db_username} #{database} > #{dump_file_path}"
      run "cd #{shared_path} && 7z a #{output_file} #{dump_file_path} && rm #{dump_file_path}"
    else
      puts "Cannot backup, adapter #{adapter} is not implemented for backup yet"
    end
    system "mkdir -p #{local_folder_path}"
    download(output_file, "#{local_folder_path}/#{file_name}.#{archive_ext}")
  end
  desc "Backup public/system folder"
  task :sys do
    file_name = "#{application}-system-#{timestamp}.7z"
    file_path = "#{shared_path}/backup/#{file_name}"
    run "7z a #{file_path} #{shared_path}/system"
    download(file_path, "#{local_folder_path}/#{file_name}")
  end
  desc "Clean backup folder"
  task :clean do
    run "rm -rfv #{shared_path}/backup/*"
  end
end
if exists?(:backup_db) && fetch(:backup_db) == true
  before "deploy:update", "backup:db"
end
if exists?(:backup_sys) && fetch(:backup_sys) == true
  before "deploy:update", "backup:sys"
end




namespace :db do
  task :create do
    run "echo \"create database #{database};\" | #{sudo} -u postgres psql"
    run "echo \"create user #{db_username} with password '#{db_password}';\" | #{sudo} -u postgres psql"
    run "echo \"grant all privileges on database booqpro_production to booqpro;\" | #{sudo} -u postgres psql"
  end
  task :seed do
    run "cd #{current_path} && bundle exec rake RAILS_ENV=#{rails_env} db:seed"
  end
end
#after "deploy:setup", "db:create"



namespace :assets do
desc "Assets precompile"
task :precompile do
#run "cd #{current_path} && bundle exec rake assets:precompile"
  if exists?(:assets) && fetch(:assets) == true
  system("bundle exec rake assets:precompile && cd public && tar czf assets.tar.gz assets/")
  upload("public/assets.tar.gz","#{current_path}/public/assets.tar.gz")
  system("rm public/assets.tar.gz")
  run("cd #{current_path}/public && rm -rf assets/ && tar xzf assets.tar.gz && rm assets.tar.gz")
  else
  puts "assets is disabled in config/deploy.rb to enable add line set :assets, true"
  end
end
end

namespace :nginx do
desc "Restart nginx"
task :restart do
  run "#{sudo} /etc/init.d/nginx restart"
end
desc "Reload nginx"
task :reload do
  run "#{sudo} /etc/init.d/nginx reload"
end
desc "Start nginx"
task :start do
  run "#{sudo} /etc/init.d/nginx start"
end
desc "Stop nginx"
task :stop do
  run "#{sudo} /etc/init.d/nginx stop"
end
desc "Add app nginx conf to server"
task :conf do
  default_nginx_template = <<-EOF
    server {
    listen  80;
    server_name  #{server_name};
    root #{current_path}/public;
    location / {
        try_files  $uri @unicorn;
    }
    location @unicorn {
        proxy_set_header  Client-Ip $remote_addr;
        proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header  Host $host;
        proxy_pass  http://unix:#{shared_path}/pids/unicorn.sock;
    }
    }
  EOF

#location = fetch(:template_dir, "config") + '/nginx.conf.erb'
#template = File.file?(location) ? File.read(location) : default_nginx_template
  config = ERB.new(default_nginx_template)
#  puts config.result
  put config.result(binding), "#{shared_path}/nginx.conf"
  run "#{sudo} ln -sfv #{shared_path}/nginx.conf /etc/nginx/sites-enabled/#{application}"
end
desc "Del nginx config"
task :delconf do
  run "#{sudo} rm -v /etc/nginx/sites-enabled/#{application}"
end
end
after "deploy:setup", "nginx:conf"
after "nginx:conf", "nginx:reload"
after "nginx:delconf", "nginx:reload"


namespace :bundle do
desc "Run bundle install"
task :install, :roles => :app, :except => {:no_release => true} do
  run "cd #{current_path} && bundle install --without development test"
end
end
namespace :log do
desc "tail -f production.log"
task :tail do
  stream("tail -f -n 0 #{current_path}/log/production.log")
end
end

desc "Create .rvmrc & files"
task :create_rvmrc do
  put rvmrc, "#{current_path}/.rvmrc"
end



namespace :install do
  desc "Install apt-nyaa"
  task :aptnyaa do
    run "#{sudo} apt-get --assume-yes install wget > /dev/null 2>&1 && cd /usr/bin/ && #{sudo} wget -Nq https://raw.github.com/nyaa/UbuntuScript/master/apt-nyaa && #{sudo} chmod +x apt-nyaa"
  end
end


namespace :sphinx do
  desc "Rebuild indexes"
  task :rebuild, :roles => :app, :except => {:no_release => true} do
    run "cd #{current_path} && bundle exec rake RAILS_ENV=#{rails_env} ts:rebuild"
  end
  desc "Sphinx start"
  task :start, :roles => :app, :except => {:no_release => true} do
    run "cd #{current_path} && bundle exec rake RAILS_ENV=#{rails_env} ts:start"
  end
  desc "Sphinx stop"
  task :stop, :roles => :app, :except => {:no_release => true} do
    run "cd #{current_path} && bundle exec rake RAILS_ENV=#{rails_env} ts:stop"
  end
  desc "Sphinx configure"
  task :stop, :roles => :app, :except => {:no_release => true} do
    run "cd #{current_path} && bundle exec rake RAILS_ENV=#{rails_env} ts:conf"
  end
  desc "Re-establish symlinks"
    task :symlink do
      if exists?(:sphinx) && fetch(:sphinx) == true
        run "mkdir -pv #{shared_path}/sphinx"
        run "rm -rf #{release_path}/db/sphinx && ln -sfv #{shared_path}/sphinx #{release_path}/db/sphinx"
      else
        puts "sphinx is disabled in config/deploy.rb to enable add line set :sphinx, true"
      end
    end
end



set :unicorn_conf, "#{current_path}/config/unicorn.rb"
set :unicorn_pid, "#{shared_path}/pids/unicorn.pid"
namespace :unicorn do
desc "start unicorn"
task :start, :roles => :app, :except => {:no_release => true} do
  run "cd #{current_path} && bundle exec unicorn -c #{unicorn_conf} -E #{rails_env} -D"
end
desc "stop unicorn"
task :stop, :roles => :app, :except => {:no_release => true} do
  run "if [ -f #{unicorn_pid} ] && [ -e /proc/$(cat #{unicorn_pid}) ]; then kill -QUIT `cat #{unicorn_pid}`; fi"
end
#desc "restart unicorn"
#task :stop, :roles => :app, :except => {:no_release => true} do
#  run "if [ -f #{unicorn_pid} ] && [ -e /proc/$(cat #{unicorn_pid}) ]; then kill -USR2 `cat #{unicorn_pid}`; else cd #{current_path} && bundle exec unicorn -c #{unicorn_conf} -E #{rails_env} -D; fi"
#end
end


after "deploy:symlink", "assets:precompile", "create_rvmrc","sphinx:symlink", "bundle:install"
after "deploy:restart","unicorn:stop", "unicorn:start"
################################
