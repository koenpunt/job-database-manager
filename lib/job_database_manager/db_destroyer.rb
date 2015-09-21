module JobDatabaseManager
  module DbDestroyer

    include BaseJob

    attr_reader :launcher

    # Job Database settings
    attr_reader :job_db_name
    attr_reader :job_db_user


    def initialize(attrs)
      @job_db_name = fix_empty(attrs['job_db_name'])
      @job_db_user = fix_empty(attrs['job_db_user']) || default_job_db_user
    end


    def perform(build, launcher, listener)
      # Set launcher in an instance variable so it's easily accessed by DbAdapter
      @launcher = launcher

      listener << "Ensuring #{db_adapter_name} database for job is removed"

      if job_db_name.nil?
        listener << "No database name configured for job.\n"
        return
      end

      drop_database(build, listener)
      drop_user(build, listener)
    end


    def drop_database(build, listener)
      begin
        listener << "Drop #{db_adapter_name} database for job if exists"
        db_connection.drop_database("#{job_db_name}_#{build.number}")
        true
      rescue DbAdapter::Error => e
        listener << error_message(e.out)
        false
      end
    end


    def drop_user(build, listener)
      begin
        listener << "Drop #{db_adapter_name} user for job if exists"
        db_connection.drop_user("#{job_db_user}_#{build.number}")
        true
      rescue DbAdapter::Error => e
        listener << error_message(e.out)
        false
      end
    end

  end
end
