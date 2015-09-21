require 'stringio'

module JobDatabaseManager
  module DbAdapter

    class Error < RuntimeError
      attr_reader :out

      def initialize(out = '')
        @out = out
      end
    end

    class AbstractAdapter

      attr_reader :launcher
      attr_reader :user
      attr_reader :password
      attr_reader :server
      attr_reader :port
      attr_reader :bin_path


      def initialize(launcher, user, password, server, port, bin_path)
        @launcher = launcher
        @user     = user
        @password = password
        @server   = server
        @port     = port
        @bin_path = bin_path
      end


      def create_database(database)
        execute create_database_query(database)
      end


      def create_user(database, user, password)
        execute create_user_query(database, user, password)
        execute create_privileges_query(database, user, password)
      end


      def drop_database(database)
        execute drop_database_query(database)
      end


      def drop_user(user)
        execute drop_privileges_query(user)
        execute drop_user_query(user)
      end


      def create_database_query(database)
        raise NotImplementedError
      end


      def create_user_query(database, user, password)
        raise NotImplementedError
      end


      def create_privileges_query(database, user, password)
        raise NotImplementedError
      end


      def drop_database_query(database)
        raise NotImplementedError
      end


      def drop_privileges_query(user)
        raise NotImplementedError
      end


      def drop_user_query(user)
        raise NotImplementedError
      end


      def db_cmd
        bin_path
      end


      def db_host
        ['--host', server]
      end


      def db_port
        ['--port', port]
      end


      def db_user
        raise NotImplementedError
      end


      def execute_query_cmd
        raise NotImplementedError
      end


      def db_query(sql)
        [execute_query_cmd, sql]
      end


      def query_cmd(sql)
        [db_cmd, *db_host, *db_port, *db_user, *db_query(sql)]
      end


      # Use this hash to pass environment variables such as DB password.
      # Example :
      # { 'MYSQL_PWD' => 'password' }
      #
      def env_vars
        {}
      end


      def execute(sql)
        out = StringIO.new()
        return out.string if sql.nil? || sql.empty?

        if launcher.execute(env_vars, query_cmd(sql), {:out => out}) != 0
          raise ::JobDatabaseManager::DbAdapter::Error.new(out.string)
        end

        out.string
      end

    end
  end
end
