require 'spec_helper_acceptance'

describe 'mysql::server' do

  describe 'running puppet code' do
    it 'should work with no errors' do
      pp = <<-EOS
        include ::mysql::server
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    it { is_expected.to contain_package('mysql-server') }
    it { is_expected.to contain_service('mysqld') }

    describe file '/etc/my.cnf' do
      it { is_expected.to be_file }
      its(:content) { should contain /mysql/ }
    end

  end
end

