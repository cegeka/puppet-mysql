Puppet::Type.type(:mysql_database).provide(:mysql) do

  desc "Manages MySQL database."

  defaultfor :kernel => 'Linux'

  optional_commands :mysql      => 'mysql'
  optional_commands :mysqladmin => 'mysqladmin'

  def self.instances
    mysql('-NBe', "show databases").split("\n").collect do |name|
      new(:name => name)
    end
  end

  def create
    mysql('-NBe', "create database `#{@resource[:name]}`")
  end

  def destroy
    mysqladmin('-f', 'drop', @resource[:name])
  end

  def exists?
    begin
      mysql('-NBe', "show databases").match(/^#{@resource[:name]}$/)
    rescue => e
      debug(e.message)
      return nil
    end
  end

end
