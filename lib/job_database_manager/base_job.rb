module JobDatabaseManager
  module BaseJob

    def error_message(message)
      "#{db_adapter_name} command failed :\n\n#{message}"
    end


    def default_job_db_user
      "#{job_db_name}_user"
    end


    def default_job_db_pass
      "#{job_db_name}_jenkins_password"
    end


    def fix_empty(s)
      s = s.strip
      s.empty? ? nil : s
    rescue
      nil
    end


    def db_user
      get_setting_value_for(:db_user)
    end


    def db_pass
      get_setting_value_for(:db_password)
    end


    def db_server_host
      get_setting_value_for(:db_server_host)
    end


    def db_server_port
      get_setting_value_for(:db_server_port)
    end


    def db_bin_path
      get_setting_value_for(:db_bin_path)
    end


    def db_connection
      begin
        klass = db_adapter_klass.constantize
      rescue => e
        raise e
      else
        klass.new(launcher, db_user, db_pass, db_server_host, db_server_port, db_bin_path)
      end
    end

  end
end
