# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = "bento/centos-7.5"
  
  # Enable SSH agent forwarding
  #config.ssh.private_key_path = "~/.ssh/id_rsa"
  #config.ssh.forward_agent = true
  
  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
    vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
    vb.memory = "1024"
    cpus = "4"
  end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  
  config.vm.provision "shell", inline: <<-SHELL
    yum install -y mc
    echo "127.0.0.1 localhost" > /etc/hosts
    echo "127.0.0.1 localhost localhost.localdomain localhost4 localhost4.localdomain4" >> /etc/hosts
    echo "::1  localhost localhost.localdomain localhost6 localhost6.localdomain6" >> /etc/hosts
    echo "192.168.56.10 apache" >> /etc/hosts
    echo "192.168.56.11 tomcat1" >> /etc/hosts
    echo "192.168.56.12 tomcat2" >> /etc/hosts
    yes | ssh-keygen -b 2048 -t rsa -f /home/vagrant/.ssh/id_rsa_key -q -N ""
    chmod 655 /home/vagrant/.ssh/id_rsa_key
    echo StrictHostKeyChecking no >> /home/vagrant/.ssh/config
    cat /vagrant/id_rsa_key.pub >> /home/vagrant/.ssh/authorized_keys
    echo PubkeyAuthentication yes >> /etc/ssh/sshd_config
  SHELL
    
  config.vm.define "apache" do |apache|
    apache.vm.hostname = "apache"
    apache.vm.network "private_network", ip: "192.168.56.10"
    apache.vm.network :forwarded_port, guest: 8080, host: 8000
    apache.vm.provision "shell", inline: <<-SHELL
      yum install -y httpd
      systemctl enable httpd
      systemctl start httpd
      cp /vagrant/mod_jk.so /etc/httpd/modules/
      touch /etc/httpd/conf.d/workers.properties
      echo "worker.list=lb" > /etc/httpd/conf.d/workers.properties
      echo "worker.lb.type=lb" >> /etc/httpd/conf.d/workers.properties
      echo "worker.lb.balance_workers=tomcat1, tomcat2" >> /etc/httpd/conf.d/workers.properties
      echo "worker.tomcat1.host=192.168.56.11" >> /etc/httpd/conf.d/workers.properties
      echo "worker.tomcat1.port=8009" >> /etc/httpd/conf.d/workers.properties
      echo "worker.tomcat1.type=ajp13" >> /etc/httpd/conf.d/workers.properties
      echo "worker.tomcat2.host=192.168.56.12" >> /etc/httpd/conf.d/workers.properties
      echo "worker.tomcat2.port=8009" >> /etc/httpd/conf.d/workers.properties
      echo "worker.tomcat2.type=ajp13" >> /etc/httpd/conf.d/workers.properties
      echo "LoadModule jk_module modules/mod_jk.so" > /etc/httpd/conf.d/httpd.conf
      echo "JkWorkersFile conf.d/workers.properties" >> /etc/httpd/conf.d/httpd.conf
      echo "JkShmFile /tmp/shm" >> /etc/httpd/conf.d/httpd.conf
      echo "JkLogFile logs/mod_jk.log" >> /etc/httpd/conf.d/httpd.conf
      echo "JkLogLevel info" >> /etc/httpd/conf.d/httpd.conf
      echo "JkMount /loadbalancer* lb" >> /etc/httpd/conf.d/httpd.conf
      systemctl restart httpd
    SHELL
  end
  
  config.vm.define "tomcat1" do |tomcat1|
    tomcat1.vm.hostname = "tomcat1"
    tomcat1.vm.network "private_network", ip: "192.168.56.11"
    tomcat1.vm.network "forwarded_port", guest: 8080, host: 8001
    tomcat1.vm.provision "shell", inline: <<-SHELL
      yum install -y tomcat tomcat-webapps tomcat-admin-webapps
      sudo mkdir /usr/share/tomcat/webapps/loadbalancer
      systemctl enable tomcat 
      systemctl start tomcat
      echo "First tomcat server is running!" > /usr/share/tomcat/webapps/loadbalancer/index.html
    SHELL
  end
  
  config.vm.define "tomcat2" do |tomcat2|
    tomcat2.vm.hostname = "tomcat2"
    tomcat2.vm.network "private_network", ip: "192.168.56.12"
    tomcat2.vm.network "forwarded_port", guest: 8080, host: 8002
    tomcat2.vm.provision "shell", inline: <<-SHELL
      yum install -y tomcat tomcat-webapps tomcat-admin-webapps
      systemctl enable tomcat 
      systemctl start tomcat
      sudo mkdir /usr/share/tomcat/webapps/loadbalancer
      echo "Second tomcat server is running!" > /usr/share/tomcat/webapps/loadbalancer/index.html
    SHELL
  end
    
end
