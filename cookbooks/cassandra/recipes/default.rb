#
# Cookbook Name:: cassandra
# Recipe:: default
#

package "sun-java6-jre" do
  action :install
end

directory "#{node[:basedir]}" do
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
  creates "/opt/cassandra"  
  action :run
end

template "/etc/cassandra/storage-conf.xml" do
  owner 'root'
  group 'root'
  mode 0644
  source "storage-conf.xml.erb"
  variables({
    :node => node
  })
end

template "/etc/cassandra/log4j.properties" do
  owner 'root'
  group 'root'
  mode 0644
  source "log4j.properties.erb"
  variables({
    :node => node
  })
end

link "/etc/cassandra/" do
  to "/opt/cassandra/"
end


