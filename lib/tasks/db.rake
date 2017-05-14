# lib/tasks/db.rake
namespace :db do

  desc "Dumps the database to db/wc2017.dump"
  task dump: :environment do
    cmd = nil
    with_config do |app, host, db, user|
      cmd = "pg_dump --host #{host} --username #{user} --verbose --clean --no-owner --no-acl --format=c #{db} > #{Rails.root}/db/#{app}.dump"
    end
    puts cmd
    exec cmd
  end

  desc "Dump a particular table to db/wc2017.table.dump (data only)"
  task dump_table: :environment do
    table_name = ENV['table']
    fail ArgumentError unless table_name
    cmd = nil
    with_config do |app, host, db, user|
      cmd = "pg_dump --table #{table_name} --host #{host} --username #{user} --verbose --data-only --no-owner --no-acl --format=c #{db} > #{Rails.root}/db/#{app}.#{table_name}.dump"
    end
    puts cmd
    exec cmd
  end

  desc "Restores the database dump at db/wc2017.dump."
  task restore: :environment do
    cmd = nil
    with_config do |app, host, db, user|
      cmd = "pg_restore --verbose --host #{host} --username #{user} --clean --no-owner --no-acl --dbname #{db} #{Rails.root}/db/#{app}.dump"
    end
    Rake::Task["db:reset"].invoke
    puts cmd
    exec cmd
  end

  desc "Restores the table dump at db/wc2017.table.dump."
  task restore_table: :environment do
    table_name = ENV['table']
    fail ArgumentError unless table_name
    ActiveRecord::Base.connection.execute("TRUNCATE #{table_name}")
    cmd = nil
    with_config do |app, host, db, user|
      cmd = "pg_restore --table #{table_name} --verbose --host #{host} --username #{user} --data-only --no-owner --no-acl --dbname #{db} #{Rails.root}/db/#{app}.#{table_name}.dump"
    end
    puts cmd
    exec cmd
  end

  private

  def with_config
    yield Rails.application.class.parent_name.underscore,
      ActiveRecord::Base.connection_config[:host],
      ActiveRecord::Base.connection_config[:database],
      ActiveRecord::Base.connection_config[:username]
  end

end
