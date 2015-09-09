module JobDatabaseManager
  autoload :BaseJob,     'job_database_manager/base_job'
  autoload :DbCreator,   'job_database_manager/db_creator'
  autoload :DbDestroyer, 'job_database_manager/db_destroyer'

  module DbAdapter
    autoload :AbstractAdapter, 'job_database_manager/db_adapter/abstract_adapter'
  end
end
