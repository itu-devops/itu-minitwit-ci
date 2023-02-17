# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = 'digital_ocean'
  config.vm.box_url = "https://github.com/devopsgroup-io/vagrant-digitalocean/raw/master/box/digital_ocean.box"
  config.ssh.private_key_path = '~/.ssh/do_ssh_key'

  config.vm.synced_folder "remote_files", "/minitwit", type: "rsync"
  
  config.vm.define "minitwit", primary: true do |server|

    server.vm.provider :digital_ocean do |provider|
      provider.ssh_key_name = "digital_ocean_ssh_key"
      provider.token = ENV["DIGITAL_OCEAN_TOKEN"]
      provider.image = 'ubuntu-20-04-x64'
      provider.region = 'fra1'
      provider.size = 's-1vcpu-1gb'
      # provider.privatenetworking = false
    end

    server.vm.hostname = "minitwit-ci-server"

    server.vm.provision "shell", inline: 'echo "export DOCKER_USERNAME=' + "'" + ENV["DOCKER_USERNAME"] + "'" + '" >> ~/.bash_profile'
    server.vm.provision "shell", inline: 'echo "export DOCKER_PASSWORD=' + "'" + ENV["DOCKER_PASSWORD"] + "'" + '" >> ~/.bash_profile'
    server.vm.provision "shell", inline: 'echo "export GH_REPO=' + "'" + ENV["GH_REPO"] + "'" + '" >> ~/.bash_profile'
    
    server.vm.provision "shell", inline: <<-SHELL
    
    # Install docker and docker-compose
    sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
    apt-cache policy docker-ce
    sudo apt install -y docker-ce
    sudo systemctl status docker
    sudo usermod -aG docker ${USER}
    sudo apt install -y docker-compose
    

    # Install make
    sudo apt-get install -y make
    
    echo -e "\nVerifying that docker works ...\n"
    docker run --rm hello-world
    docker rmi hello-world

    echo -e "\nOpening port for minitwit ...\n"
    ufw allow 5000 && \
    ufw allow 22/tcp

    echo ". $HOME/.bashrc" >> $HOME/.bash_profile

    echo -e "\nConfiguring credentials as environment variables...\n"

    source $HOME/.bash_profile

    echo -e "\nSelecting Minitwit Folder as default folder when you ssh into the server...\n"
    echo "cd /minitwit" >> ~/.bash_profile

    
    echo -e "\nVagrant setup done ..."
    echo -e "minitwit will later be accessible at http://$(hostname -I | awk '{print $1}'):5000"
    echo -e "The mysql database needs a minute to initialize, if the landing page is stack-trace ..."
    SHELL
  end
end
