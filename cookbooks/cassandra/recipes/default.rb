#
# Cookbook Name:: cassandra
# Recipe:: default
#

package "openjdk-6-jre" do
  action :install
end

directory "#{node[:basedir]}" do
  owner node[:owner_name]
  group node[:owner_name]
  mode 0755
  recursive true
end

directory "#{node[:basedir]}/logs" do
  owner node[:owner_name]
  group node[:owner_name]
  mode 0755
  recursive true
end

remote_file "/opt/cassandra.tgz" do
  source "http://apache.mirror.facebook.net/incubator/cassandra/0.3.0/apache-cassandra-incubating-0.3.0-bin.tar.gz"
  mode "0644"
  checksum "bfbb9cd29866ac31217f72c57e277a67" # A SHA256 (or portion thereof) of the file.
end

execute "untar" do
  cwd "/opt"
  command "tar -zxf cassandra.tgz"
  creates "/opt/apache-cassandra-incubating-0.3.0"  
  action :run
end

execute "rename original conf files" do
  cwd "/opt/apache-cassandra-incubating-0.3.0/conf"
  command "rename 's/$/\.orig/' ./*"
  creates "/opt/apache-cassandra-incubating-0.3.0"  
  action :run
end

link "/opt/cassandra" do
  to "/opt/apache-cassandra-incubating-0.3.0"
end

link "/etc/cassandra" do
  to "/opt/cassandra/conf"
end

template "/opt/apache-cassandra-incubating-0.3.0/conf/storage-conf.xml" do
  owner 'root'
  group 'root'
  mode 0644
  source "storage-conf.xml.erb"
end

template "/opt/apache-cassandra-incubating-0.3.0/conf/log4j.properties" do
  owner 'root'
  group 'root'
  mode 0644
  source "log4j.properties.erb"
end

execute "ensure-cassandra-is-running" do
  returns 1 
  command %Q{
    /opt/cassandra/bin/cassandra --host localhost --port 9160
  }
  not_if "pgrep -f org.apache.cassandra.service.CassandraDaemon"
end


