module JobDatabaseManager
  module DbCreator

    include BaseJob

    attr_reader :launcher

    # Job Database settings
    attr_reader :job_db_name
    attr_reader :job_db_user
    attr_reader :job_db_pass
    attr_reader :job_create_user


    def initialize(attrs)
      @job_db_name = fix_empty(attrs['job_db_name'])
      @job_db_user = fix_empty(attrs['job_db_user']) || default_job_db_user
      @job_db_pass = fix_empty(attrs['job_db_pass']) || default_job_db_pass
      @job_create_user = get_bool(attrs['job_create_user'])
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

      unless create_database(build, listener)
        build.abort
        return
      end

      if create_user?
        unless create_user(build, listener)
          build.abort
          return
        end
      end
      set_environment_variables(build)
    end


    def create_user?
      job_create_user
    end


    def create_database(build, listener)
      catch_errors(listener) do
        listener << "Creating #{db_adapter_name} database for job"
        db_connection.create_database("#{job_db_name}_#{build.number}")
      end
    end


    def create_user(build, listener)
      catch_errors(listener) do
        listener << "Creating #{db_adapter_name} user for job"
        db_connection.create_user("#{job_db_name}_#{build.number}", "#{job_db_user}_#{build.number}", job_db_pass)
      end
    end


    private

      def set_environment_variables(build)
        build.env["#{db_adapter_type.to_s.upcase}_DATABASE"] = "#{job_db_name}_#{build.number}"
        build.env["#{db_adapter_type.to_s.upcase}_USER"]     = create_user? ? "#{job_db_user}_#{build.number}" : db_user
        build.env["#{db_adapter_type.to_s.upcase}_PASSWORD"] = create_user? ? job_db_pass : db_pass
        build.env["#{db_adapter_type.to_s.upcase}_HOST"]     = db_server_host
        build.env["#{db_adapter_type.to_s.upcase}_PORT"]     = db_server_port
      end

  end
end
