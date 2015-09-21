require 'spec_helper'

describe JobDatabaseManager::DbDestroyer do

  let(:klass) { build_db_destroyer }


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


  describe '#perform' do
    before do
      @build      = double('build')
      @launcher   = double('launcher')
      @listener   = double('listener')
      @adapter    = build_adapter
    end

    context 'when job db_name is nil' do
      it 'should escape performer' do
        klass = build_db_destroyer('job_db_name' => nil)
        expect(klass).to receive(:db_adapter_name).and_return('MySQL')
        expect(@listener).to receive(:<<).at_least(:once)
        klass.perform(@build, @launcher, @listener)
      end
    end

    context 'when job_db_name is set' do
      it 'should abort build' do
        expect(klass).to receive(:db_adapter_name).at_least(:once).and_return('MySQL')
        expect(klass).to receive(:drop_database).at_least(:once).and_return(false)
        expect(klass).to receive(:drop_user).at_least(:once).and_return(false)

        expect(@listener).to receive(:<<).at_least(:once)

        klass.perform(@build, @launcher, @listener)
      end
    end
  end


  describe '#drop_database' do
    before do
      @build    = double('build')
      @listener = double('listener')
      @adapter  = build_adapter
    end


    context 'when task success' do
      it 'should return true' do
        expect(klass).to receive(:db_adapter_name).at_least(:once).and_return('MySQL')
        expect(klass).to receive(:db_connection).and_return(@adapter)

        expect(@adapter).to receive(:drop_database).and_return(true)
        expect(@build).to receive(:number).and_return(1)
        expect(@listener).to receive(:<<).at_least(:once)

        expect(klass.drop_database(@build, @listener)).to be true
      end
    end

    context 'when task fails' do
      it 'should return false' do
        expect(klass).to receive(:db_adapter_name).at_least(:once).and_return('MySQL')
        expect(klass).to receive(:db_connection).and_return(@adapter)

        expect(@build).to receive(:number).at_least(:once).and_return(1)
        expect(@adapter).to receive(:drop_database).and_raise(JobDatabaseManager::DbAdapter::Error)
        expect(@listener).to receive(:<<).at_least(:once)

        expect(klass.drop_database(@build, @listener)).to be false
      end
    end
  end


  describe '#drop_user' do
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
        expect(@adapter).to receive(:drop_user).and_return(true)
        expect(@listener).to receive(:<<).at_least(:once)

        expect(klass.drop_user(@build, @listener)).to be true
      end
    end

    context 'when task fails' do
      it 'should return false' do
        expect(klass).to receive(:db_adapter_name).at_least(:once).and_return('MySQL')
        expect(klass).to receive(:db_connection).and_return(@adapter)

        expect(@build).to receive(:number).at_least(:once).and_return(1)
        expect(@adapter).to receive(:drop_user).and_raise(JobDatabaseManager::DbAdapter::Error)
        expect(@listener).to receive(:<<).at_least(:once)

        expect(klass.drop_user(@build, @listener)).to be false
      end
    end
  end

end
