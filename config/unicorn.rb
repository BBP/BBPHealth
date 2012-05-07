worker_processes 3

app_directory = '/home/bbphealth/www'

working_directory "#{app_directory}/current"

listen 7000
timeout 600

preload_app true

pid "#{app_directory}/shared/pids/unicorn.pid"

stderr_path "#{app_directory}/shared/log/unicorn.stderr.log"
stdout_path "#{app_directory}/shared/log/unicorn.stdout.log"

if GC.respond_to?(:copy_on_write_friendly=)
  GC.copy_on_write_friendly = true
end

before_fork do |server, worker|
  old_pid = "#{app_directory}/shared/pids/unicorn.pid.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
  # the following is recomended for Rails + "preload_app true"
  # as there's no need for the master process to hold a connection
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection.disconnect!
  end
end

after_fork do |server, worker|
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
  end
end
