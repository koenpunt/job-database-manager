module JobDatabaseManager
  module DbCreator

    include BaseJob

    attr_reader :launcher

    # Job Database settings
    attr_reader :job_db_name
    attr_reader :job_db_user
    attr_reader :job_db_pass


    def initialize(attrs)
      @job_db_name = fix_empty(attrs['job_db_name'])
      @job_db_user = fix_empty(attrs['job_db_user']) || default_job_db_user
      @job_db_pass = fix_empty(attrs['job_db_pass']) || default_job_db_pass
    end


    def setup(build, launcher, listener)
      # Set launcher in an instance variable so it's easily accessed by DbAdapter
      @launcher = launcher

      listener << "Ensuring #{db_adapter_name} database for job exists"

      if job_db_name.nil?
        listener << "No database name configured for job.\n"
        build.abort
        return
      end

      if create_database(build, listener)
        if create_user(build, listener)
          set_environment_variables(build)
        else
          build.abort
        end
      else
        build.abort
      end
    end


    def create_database(build, listener)
      begin
        listener << "Creating #{db_adapter_name} database for job"
        db_connection.create_database("#{job_db_name}_#{build.number}")
        true
      rescue DbAdapter::Error => e
        listener << error_message(e.out)
        false
      end
    end


    def create_user(build, listener)
      begin
        listener << "Creating #{db_adapter_name} user for job"
        db_connection.create_user("#{job_db_name}_#{build.number}", "#{job_db_user}_#{build.number}", job_db_pass)
        true
      rescue DbAdapter::Error => e
        listener << error_message(e.out)
        false
      end
    end


    private


      def set_environment_variables(build)
        build.env["#{db_adapter_type.to_s.upcase}_DATABASE"] = "#{job_db_name}_#{build.number}"
        build.env["#{db_adapter_type.to_s.upcase}_USER"]     = "#{job_db_user}_#{build.number}"
        build.env["#{db_adapter_type.to_s.upcase}_PASSWORD"] = job_db_pass
        build.env["#{db_adapter_type.to_s.upcase}_HOST"]     = db_server_host
        build.env["#{db_adapter_type.to_s.upcase}_PORT"]     = db_server_port
      end

  end
end
