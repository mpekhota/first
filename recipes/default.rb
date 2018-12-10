#
# Cookbook:: bluegreen
# Recipe:: default
#
# Copyright:: 2018, Mikhail Pekhota, All Rights Reserved.

docker_service 'default' do
    action [:create, :start]
end

docker_image "#{node['registry']['url']}" do
    tag node['registry']['version']
    action :pull
end

isBlueRunning = `docker ps | grep '8080->' -c`

if isBlueRunning == 0
    docker_container 'nodeBlue' do
        repo "#{node['registry']['url']}"
        tag node['registry']['version']
        port '8080:8080'
    end	
    docker_container 'nodeGreen' do
        action [:kill, :delete]
    end
else
    docker_container 'nodeGreen' do
        repo "#{node['registry']['url']}"
        tag node['registry']['version']
        port '8081:8080'
    end 
    docker_container 'nodeBlue' do
        action [:kill, :delete]
    end
end
