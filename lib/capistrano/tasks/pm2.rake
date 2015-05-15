require 'json'

namespace :pm2 do

  def app_status
    within current_path do
      ps = JSON.parse(capture :pm2, :jlist, fetch(:pm2_name))
      if ps.empty?
        return nil
      else
        # status: online, errored, stopped
        return ps[0]["pm2_env"]["status"]
      end
    end
  end

  def restart_app
    within current_path do
      execute :pm2, :restart, fetch(:pm2_name)
    end
  end

  def stop_app
    within current_path do
      execute :pm2, :stop, fetch(:pm2_name)
    end
  end

  def delete_current
    within current_path do
      execute :pm2, :stop, fetch(:pm2_name)
      execute :pm2, :delete, fetch(:pm2_name)
    end
  end

  def start_app
    within current_path do
      env = fetch(:default_env)['NODE_ENV']
      execute "cd #{current_path} && NODE_ENV=#{env} pm2 start #{fetch(:app_command)} --name #{fetch(:pm2_name)}"
    end
  end

  desc 'Restart app gracefully'
  task :restart do
    on roles(:app) do
      case app_status
      when nil
        info 'App is not registerd'
        start_app
      when 'stopped'
        info 'App is stopped'
        start_app
      when 'errored'
        info 'App has errored'
        restart_app
      when 'online'
        info 'App is online'
        restart_app
      end
    end
  end

end