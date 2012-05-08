#############################################################
# Application
#############################################################
set :application, "bbphealth"
set :deploy_to, "/home/#{application}/www"

#############################################################
# Settings
#############################################################

default_run_options[:pty] = true
ssh_options[:forward_agent] = true
set :use_sudo, true
set :scm_verbose, true
set :rails_env, "production" 

#############################################################
# Servers
#############################################################

set :user,     'bbphealth' 
set :port,     22

role :web, "178.33.230.51"      
role :app, "178.33.230.51"      
role :db,  "178.33.230.51", :primary => true  

#############################################################
# Git
#############################################################
set :scm,         :git
set :deploy_via,  :remote_cache
set :scm_verbose, true
set :use_sudo,    false

set :repository, "git@github.com:xilinus/bbphealth.git"
set :branch,     'master'

set :rake,     '$HOME/.rbenv/shims/rake'

set :current_path, "/home/#{application}/www/current"
set :unicorn_binary, "unicorn_rails"
set :unicorn_config, "#{current_path}/config/unicorn.rb"
set :unicorn_pid, "#{current_path}/tmp/pids/unicorn.pid"

namespace :deploy do
  task :start, :roles => :app, :except => { :no_release => true } do 
    run "cd #{current_path} && bundle exec #{unicorn_binary} -c #{unicorn_config} -E #{rails_env} -D"
  end
  task :stop, :roles => :app, :except => { :no_release => true } do 
    run "kill `cat #{unicorn_pid}`"
  end
  task :graceful_stop, :roles => :app, :except => { :no_release => true } do
    run "kill -s QUIT `cat #{unicorn_pid}`"
  end
  task :reload, :roles => :app, :except => { :no_release => true } do
    run "kill -s USR2 `cat #{unicorn_pid}`"
  end
  task :restart do
  end

  after "deploy:restart", "deploy:reload"
end

set :default_environment, {
  'PATH' => "/home/#{application}/.rbenv/shims:/home/#{application}/.rbenv/bin:$PATH"
}

after 'deploy:finalize_update', 'bundle:install'

namespace :bundle do
  task :install do
    run "cd #{release_path}; bundle install --deployment --binstubs --shebang ruby-local-exec --without test:development:cucumber --path #{shared_path}/bundle"
  end
end

after 'deploy:update_code' do
  # run "cp #{shared_path}/resources/database.yml #{release_path}/config/"  
  # run "cd #{release_path}/public; ln -s #{shared_path}/uploads ."
  # # run "cd #{release_path}; RAILS_ENV=production bundle exec rake barista:brew"
  # run "cd #{release_path}; RAILS_ENV=production bundle exec jammit"
  run "cd #{release_path}; bundle exec rake assets:precompile"
end