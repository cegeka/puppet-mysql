require 'spec_helper_acceptance'

describe 'mysql::rights' do

  describe 'running puppet code' do
    it 'should work with no errors' do
      pp = <<-EOS
        include ::mysql::server

        mysql::rights { 'testdb':
          ensure   => present,
          database => 'testdb',
          user     => 'testuser',
          password => 'testpwd',
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

