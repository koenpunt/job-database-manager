require 'spec_helper'

describe JobDatabaseManager::DbCreator do

  class FooBuilder
    include JobDatabaseManager::DbCreator
  end

  class FooAdapter < JobDatabaseManager::DbAdapter::AbstractAdapter
  end


  def build_klass
    klass = FooBuilder.new({
      'job_db_name' => 'foo_db',
      'job_db_user' => 'foo_user',
      'job_db_pass' => 'foo_pass'
    })
    klass
  end

  let(:klass) { build_klass }

  subject { klass }

  it { should respond_to(:setup) }


  describe '#error_message' do
    it 'should return a formated error message' do
      expect(klass).to receive(:db_adapter_name).and_return('MySQL')
      expect(klass.error_message('foo')).to eq "MySQL command failed :\n\nfoo"
    end
  end


  describe '#default_job_db_user' do
    it 'should return the db user for the job' do
      expect(klass.default_job_db_user).to eq 'foo_db_user'
    end
  end


  describe '#default_job_db_pass' do
    it 'should return the db pass for the job' do
      expect(klass.default_job_db_pass).to eq 'foo_db_jenkins_password'
    end
  end


  describe '#fix_empty' do
    context 'when string is empty' do
      it 'should return nil' do
        expect(klass.fix_empty('')).to be nil
      end
    end
    context 'when string is nil' do
      it 'should return nil' do
        expect(klass.fix_empty(nil)).to be nil
      end
    end
    context 'when string is set' do
      it 'should return stripped string' do
        expect(klass.fix_empty(' foo ')).to eq 'foo'
      end
    end
  end


  describe '#db_user' do
    it 'should return the db user used to setup the job db' do
      expect(klass).to receive(:get_setting_value_for).with(:db_user).and_return('root')
      expect(klass.db_user).to eq 'root'
    end
  end


  describe '#db_pass' do
    it 'should return the db user used to setup the job db' do
      expect(klass).to receive(:get_setting_value_for).with(:db_password).and_return('root_pass')
      expect(klass.db_pass).to eq 'root_pass'
    end
  end


  describe '#db_server_host' do
    it 'should return the db host used to setup the job db' do
      expect(klass).to receive(:get_setting_value_for).with(:db_server_host).and_return('localhost')
      expect(klass.db_server_host).to eq 'localhost'
    end
  end


  describe '#db_server_port' do
    it 'should return the db port used to setup the job db' do
      expect(klass).to receive(:get_setting_value_for).with(:db_server_port).and_return(3306)
      expect(klass.db_server_port).to eq 3306
    end
  end


  describe '#db_bin_path' do
    it 'should return the db bin path used to setup the job db' do
      expect(klass).to receive(:get_setting_value_for).with(:db_bin_path).and_return('/usr/bin/mysql')
      expect(klass.db_bin_path).to eq '/usr/bin/mysql'
    end
  end


  describe '#db_connection' do
    context 'when adapter exists' do
      it 'should invoke it with params' do
        adapter = 'FooAdapter'
        expect(klass).to receive(:db_adapter_klass).and_return(adapter)
        expect(klass).to receive(:get_setting_value_for).at_least(:once)
        expect(adapter).to receive(:constantize).and_return(FooAdapter)
        klass.db_connection
      end
    end

    context 'when adapter dont exist' do
      it 'should raise an error' do
        adapter = 'BarAdapter'
        expect(klass).to receive(:db_adapter_klass).and_return(adapter)
        expect(adapter).to receive(:constantize).and_raise(NameError)
        expect {
          klass.db_connection
        }.to raise_error(NameError)
      end
    end
  end

end
