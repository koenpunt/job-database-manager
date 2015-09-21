require 'spec_helper'

describe JobDatabaseManager::DbAdapter::AbstractAdapter do

  let(:klass) { build_adapter }


  describe '#create_database' do
    it 'should create the database passed in param' do
      expect(klass).to receive(:create_database_query).with('bar').and_return('bar')
      expect(klass).to receive(:execute).with('bar')
      klass.create_database('bar')
    end
  end


  describe '#create_user' do
    it 'should create the user passed in param' do
      expect(klass).to receive(:create_user_query).with('bar', 'foo', 'pass').and_return('foo')
      expect(klass).to receive(:execute).with('foo')
      klass.create_user('bar', 'foo', 'pass')
    end
  end


  describe '#drop_database' do
    it 'should drop the database passed in param' do
      expect(klass).to receive(:drop_database_query).with('foo').and_return('foo')
      expect(klass).to receive(:execute).with('foo')
      klass.drop_database('foo')
    end
  end


  describe '#drop_user' do
    it 'should drop the user passed in param' do
      expect(klass).to receive(:drop_privilege_query).with('foo').and_return('foo')
      expect(klass).to receive(:drop_user_query).with('foo').and_return('foo')
      expect(klass).to receive(:execute).with('foo')
      expect(klass).to receive(:execute).with('foo')
      klass.drop_user('foo')
    end
  end

  describe '#create_database_query' do
    it 'should raise an error' do
      expect {
        klass.create_database_query('database')
      }.to raise_error(NotImplementedError)
    end
  end


  describe '#create_user_query' do
    it 'should raise an error' do
      expect {
        klass.create_user_query('database', 'user', 'password')
      }.to raise_error(NotImplementedError)
    end
  end


  describe '#drop_database_query' do
    it 'should raise an error' do
      expect {
        klass.drop_database_query('database')
      }.to raise_error(NotImplementedError)
    end
  end


  describe '#drop_privilege_query' do
    it 'should raise an error' do
      expect {
        klass.drop_privilege_query('user')
      }.to raise_error(NotImplementedError)
    end
  end


  describe '#drop_user_query' do
    it 'should raise an error' do
      expect {
        klass.drop_user_query('user')
      }.to raise_error(NotImplementedError)
    end
  end


  describe '#db_cmd' do
    it 'should return db_cmd' do
      expect(klass.db_cmd).to eq '/usr/bin/mysql'
    end
  end


  describe '#db_host' do
    it 'should return db_host' do
      expect(klass.db_host).to eq ['--host', '127.0.0.1']
    end
  end


  describe '#db_port' do
    it 'should return db_port' do
      expect(klass.db_port).to eq ['--port', 3306]
    end
  end


  describe '#db_user' do
    it 'should return db_user' do
      expect {
        klass.db_user
      }.to raise_error(NotImplementedError)
    end
  end


  describe '#execute_query_cmd' do
    it 'should return execute_query_cmd' do
      expect {
        klass.execute_query_cmd
      }.to raise_error(NotImplementedError)
    end
  end


  describe '#db_query' do
    it 'should return pre built command line' do
      expect(klass).to receive(:execute_query_cmd).and_return('')
      expect(klass.db_query('foo')).to eq ['', 'foo']
    end
  end


  describe '#query_cmd' do
    it 'should return pre built command line' do
      expect(klass).to receive(:db_user).and_return(['--user', 'foo_user'])
      expect(klass).to receive(:execute_query_cmd).and_return('--execute')
      expect(klass.query_cmd('foo_query')).to eq ['/usr/bin/mysql', '--host', '127.0.0.1', '--port', 3306, '--user', 'foo_user', '--execute', 'foo_query']
    end
  end


  describe '#env_vars' do
    it 'should return a hash of environment variables' do
      expect(klass.env_vars).to eq({})
    end
  end

  describe '#execute' do
    context 'when command is nil' do
      it 'should return empty string' do
        expect(klass.execute(nil)).to eq ''
        expect(klass.execute('')).to  eq ''
      end
    end

    context 'when command success' do
      it 'should return the result of the command' do
        launcher = double('launcher')
        klass = FooAdapter.new(launcher, 'foo', 'pass', '127.0.0.1', 3306, '/usr/bin/mysql')

        expect(klass).to receive(:db_user).and_return(['--user', 'foo_user'])
        expect(klass).to receive(:execute_query_cmd).and_return('--execute')

        expect(launcher).to receive(:execute).and_return(0)
        expect(klass.execute('foo')).to eq ''
      end
    end

    context 'when command failed' do
      it 'should raise an error' do
        launcher = double('launcher')
        klass = FooAdapter.new(launcher, 'foo', 'pass', '127.0.0.1', 3306, '/usr/bin/mysql')

        expect(klass).to receive(:db_user).and_return(['--user', 'foo_user'])
        expect(klass).to receive(:execute_query_cmd).and_return('--execute')

        expect(launcher).to receive(:execute).and_return(1)
        expect {
          klass.execute('foo')
        }.to raise_error(JobDatabaseManager::DbAdapter::Error)
      end
    end

  end
end
