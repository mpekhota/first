#
# Cookbook:: bluegreen
# Recipe:: default
#
# Copyright:: 2018, Mikhail Pekhota, All Rights Reserved.

docker_service 'default' do
    action [:create, :start]
end

docker_image "#{node['bluegreen']['url']}/bluegreen" do
    tag node['bluegreen']['version']
    action :pull
end