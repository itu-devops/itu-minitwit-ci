# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = 'digital_ocean'
  config.vm.box_url = "https://github.com/devopsgroup-io/vagrant-digitalocean/raw/master/box/digital_ocean.box"
  config.ssh.private_key_path = 'ssh_keys/do_ssh_key'

  # config.vm.synced_folder "vagrant_files", "/vagrant", type: "rsync"
  config.vm.provision "file", source: "./docker-compose.yml", destination: "docker-compose.yml"

  config.vm.define "minitwit", primary: true do |server|

    server.vm.provider :digital_ocean do |provider|
      provider.ssh_key_name = ENV["SSH_KEY_NAME"]
      provider.token = ENV["DIGITAL_OCEAN_TOKEN"]
      provider.image = 'docker-18-04'
      provider.region = 'fra1'
      provider.size = '1gb'
      provider.privatenetworking = true
    end

    server.vm.hostname = "minitwit-ci-server"
    server.vm.provision "shell", inline: <<-SHELL

    echo -e "\nVerifying that docker works ...\n"
    docker run --rm hello-world
    docker rmi hello-world

    echo -e "\nOpening port for minitwit ...\n"
    ufw allow 5000

    echo -e "\nStart minitwit with docker-compose ...\n"
    cd /vagrant
    docker-compose up -d

    echo -e "\nVagrant setup done ..."
    echo -e "minitwit should be accessible at http://$(hostname -I | awk '{print $1}'):5000"
    echo -e "The mysql database needs a minute to initialize, if the landing page is stack-trace ..."
    SHELL
  end
end
