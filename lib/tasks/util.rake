namespace "postgres" do
  task :start do
    system("/opt/local/lib/postgresql84/bin/pg_ctl -D /Users/yostinso/Documents/Projects/JSQueuedUploads/db/postgres_netrig start")
  end
  task :stop => [ "delayed_job:stop" ] do
    system("/opt/local/lib/postgresql84/bin/pg_ctl -D /Users/yostinso/Documents/Projects/JSQueuedUploads/db/postgres_netrig stop")
  end
end

namespace "delayed_job" do
  task :start => [ "postgres:start"] do
    system("./script/delayed_job start")
  end
  task :stop do
    system("./script/delayed_job stop")
  end
end

task :start_prereqs => [ "postgres:start", "delayed_job:start" ]
task :stop_prereqs => [ "delayed_job:stop", "postgres:stop" ]