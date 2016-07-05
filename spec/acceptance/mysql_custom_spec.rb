require 'spec_helper_acceptance'

describe 'mysql::database' do

  describe 'running puppet code' do
    it 'should work with no errors' do
      pp = <<-EOS
        class { '::mysql::server':
            data_dir => '/data/',
        }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe file '/etc/my.cnf' do
      it { is_expected.to be_file }
      its(:content) { should contain /data/ }
    end

    describe process('mysqld') do
      it { should be_running }
    end
  end
end

