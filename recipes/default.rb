#
# Cookbook Name:: jkeyes-python2
# Recipe:: default
#

["build-essential",
"libncursesw5-dev",
"libreadline-dev",
"libssl-dev",
"libgdbm-dev",
"libc6-dev",
"libsqlite3-dev",
"tar",
"wget"
].each do |pkg|
  package pkg do
    action :install
  end
end


version = "2.7.5"
version_short = version[0, version.length - 2]
configure_options = ""


# install python 2.7
remote_file "#{Chef::Config[:file_cache_path]}/Python-#{version}.tar.bz2" do
  source "http://www.python.org/ftp/python/#{version}/Python-#{version}.tar.bz2"
  checksum "7dffe775f3bea68a44f762a3490e5e28"
  mode "0644"
  # not_if { ::File.exists?(install_path) }
end

bash "build-and-install-python" do
  cwd Chef::Config[:file_cache_path]
  code <<-EOF
    tar -jxvf Python-#{version}.tar.bz2
    (cd Python-#{version} && ./configure #{configure_options})
    (cd Python-#{version} && make && make install)
  EOF
  creates "/usr/local/bin/python#{version}"
  # not_if { ::File.exists?(install_path) }
end

# remote_file "#{Chef::Config[:file_cache_path]}/Python-#{version}.tar.bz2" do
bash "setup easy_install" do
  code <<-EOF
    wget https://bitbucket.org/pypa/setuptools/raw/0.8/ez_setup.py -O - | python#{version_short}
  EOF
end

remote_file "#{Chef::Config[:file_cache_path]}/setuptools-0.8.tar.gz" do
  source "https://pypi.python.org/packages/source/s/setuptools/setuptools-0.8.tar.gz"
  checksum "7dffe775f3bea68a44f762a3490e5e28"
  mode "0644"
end

bash "setup easy_install" do
  cwd Chef::Config[:file_cache_path]
  code <<-EOF
    tar -zxvf setuptools-0.8.tar.gz
    cd setuptools-0.8
    python#{version_short} ez_setup.py --user
  EOF
end

easy_install_package "pip" do
  action :install
end

package "nodejs" do
  action :install
end
