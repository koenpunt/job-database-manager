require 'spec_helper'

describe JobDatabaseManager::DbCreator do

  let(:klass) { build_db_creator }


  describe '#job_db_name' do
    it 'should return the db_name used for the job' do
      expect(klass.job_db_name).to eq 'foo_db'
    end
  end


  describe '#job_db_user' do
    it 'should return the db_user used for the job' do
      expect(klass.job_db_user).to eq 'foo_user'
    end
  end


  describe '#job_db_pass' do
    it 'should return the db_pass used for the job' do
      expect(klass.job_db_pass).to eq 'foo_pass'
    end
  end


  describe '#setup' do
    before do
      @build      = double('build')
      @launcher   = double('launcher')
      @listener   = double('listener')
      @adapter    = build_adapter
    end

    context 'when job db_name is nil' do
      it 'should abort build' do
        klass = build_db_creator('job_db_name' => nil)
        expect(klass).to receive(:db_adapter_name).and_return('MySQL')
        expect(@listener).to receive(:<<).at_least(:once)
        expect(@build).to receive(:abort)
        klass.setup(@build, @launcher, @listener)
      end
    end

    context 'when job_db_name is set' do
      context 'when the job success' do
        it 'should return nothing' do
          expect(klass).to receive(:db_adapter_name).at_least(:once).and_return('MySQL')
          expect(klass).to receive(:db_adapter_type).at_least(:once).and_return('mysql')
          expect(klass).to receive(:db_connection).at_least(:twice).and_return(@adapter)
          expect(klass).to receive(:get_setting_value_for).at_least(:twice)

          expect(@listener).to receive(:<<).at_least(:once)
          expect(@build).to receive(:number).at_least(:once).and_return(1)
          expect(@build).to receive(:env).at_least(:once).and_return({ 'foo' => 'bar' })

          expect(@adapter).to receive(:create_database)
          expect(@adapter).to receive(:create_user)

          klass.setup(@build, @launcher, @listener)
        end
      end

      context 'when the first step of the job fails' do
        it 'should abort build' do
          expect(klass).to receive(:db_adapter_name).and_return('MySQL')
          expect(klass).to receive(:create_database).at_least(:once).and_return(false)
          expect(@listener).to receive(:<<).at_least(:once)
          expect(@build).to receive(:abort)
          klass.setup(@build, @launcher, @listener)
        end
      end

      context 'when the second step of the job fails' do
        it 'should abort build' do
          expect(klass).to receive(:db_adapter_name).and_return('MySQL')
          expect(klass).to receive(:create_database).at_least(:once).and_return(true)
          expect(klass).to receive(:create_user).at_least(:once).and_return(false)
          expect(@listener).to receive(:<<).at_least(:once)
          expect(@build).to receive(:abort)
          klass.setup(@build, @launcher, @listener)
        end
      end
    end
  end


  describe '#create_database' do
    before do
      @build    = double('build')
      @listener = double('listener')
      @adapter  = build_adapter
    end


    context 'when task success' do
      it 'should return true' do
        expect(klass).to receive(:db_adapter_name).at_least(:once).and_return('MySQL')
        expect(klass).to receive(:db_connection).and_return(@adapter)
        expect(@build).to receive(:number).and_return(1)
        expect(@listener).to receive(:<<).at_least(:once)

        expect(@adapter).to receive(:create_database).and_return(true)
        expect(klass.create_database(@build, @listener)).to be true
      end
    end

    context 'when task fails' do
      it 'should return false' do
        expect(klass).to receive(:db_adapter_name).at_least(:once).and_return('MySQL')
        expect(klass).to receive(:db_connection).and_return(@adapter)
        expect(@build).to receive(:number).at_least(:once).and_return(1)
        expect(@listener).to receive(:<<).at_least(:once)

        expect(@adapter).to receive(:create_database).and_raise(JobDatabaseManager::DbAdapter::Error)
        expect(klass.create_database(@build, @listener)).to be false
      end
    end
  end


  describe '#create_user' do
    before do
      @build    = double('build')
      @listener = double('listener')
      @adapter  = build_adapter
    end

    context 'when task success' do
      it 'should return true' do
        expect(klass).to receive(:db_adapter_name).at_least(:once).and_return('MySQL')
        expect(klass).to receive(:db_connection).and_return(@adapter)
        expect(@build).to receive(:number).at_least(:once).and_return(1)
        expect(@listener).to receive(:<<).at_least(:once)

        expect(@adapter).to receive(:create_user).and_return(true)
        expect(klass.create_user(@build, @listener)).to be true
      end
    end

    context 'when task fails' do
      it 'should return false' do
        expect(klass).to receive(:db_adapter_name).at_least(:once).and_return('MySQL')
        expect(klass).to receive(:db_connection).and_return(@adapter)
        expect(@build).to receive(:number).at_least(:once).and_return(1)
        expect(@listener).to receive(:<<).at_least(:once)

        expect(@adapter).to receive(:create_user).and_raise(JobDatabaseManager::DbAdapter::Error)
        expect(klass.create_user(@build, @listener)).to be false
      end
    end
  end

end
