require 'spec_helper_acceptance'

describe 'mysql::database' do

  describe 'running puppet code' do
    it 'should work with no errors' do
      pp = <<-EOS
        include ::mysql::server

        mysql::database { 'testdb':
          ensure => present
        }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe file '/etc/my.cnf' do
      it { is_expected.to be_file }
      its(:content) { should contain /mysqld/ }
    end

  end
end

