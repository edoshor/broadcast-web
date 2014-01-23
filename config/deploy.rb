require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require 'mina/rbenv'

set :domain, 'staging'
set :deploy_to, '/var/www/broadcast-web'
set :repository, 'https://github.com/edoshor/broadcast-web'
set :branch, 'master'
set :shared_paths, %w(config/database.yml config/thin-example.yml environments/production.yml)
set :user, 'deploy'


set :rbenv_path, '/usr/local/rbenv'
task :environment do
  # required for system wide installation of rbenv
  queue %{export RBENV_ROOT=#{rbenv_path}}
  invoke :'rbenv:load'
end

task :setup => :environment do
  queue! %[mkdir -p "#{deploy_to}/shared/config"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/config"]

  queue! %[touch "#{deploy_to}/shared/config/database.yml"]
  queue %[echo "-----> Be sure to edit 'shared/config/database.yml'."]

  queue! %[touch "#{deploy_to}/shared/config/environments/production.yml"]
  queue %[echo "-----> Be sure to edit 'shared/config/environments/production.yml'."]

  queue! %[touch "#{deploy_to}/shared/config/thin-example.yml"]
  queue %[echo "-----> Be sure to edit 'shared/config/thin-example.yml'."]
end

desc 'Deploys the current version to the server.'
task :deploy => :environment do
  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'

    to :launch do
      queue %{
          if [ -f $(cat config/thin-example.yml | grep pid: | sed '/^pid: */!d; s///;q') ];
          then
            echo "thin is up. restarting"
            bundle exec thin -C config/thin-example.yml restart
            exit
          else
            echo "thin is down. starting"
            bundle exec thin -C config/thin-example.yml start
            exit
          fi
      %}
    end
  end
end