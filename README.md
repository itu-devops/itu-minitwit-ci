# ITU-MiniTwit CI/CD Scenario

## 1.) Requirements


  * In case you are not already, register at Docker Hub (https://hub.docker.com/) 
    - To make a later step more straight forward, use a password without any special characters.
    - From now on we refer to your login ID from Docker Hub as `DOCKER_USERNAME` and your password there is called `DOCKER_PASSWORD`.
  * Login at Docker Hub and create three public repositories with the following names (by clicking the big blue `Create Repository` button in the top right).
    - `mysqlimage`
    - `minitwitimage`
    - `flagtoolimage`
  * You need to be signed up at DigitalOcean (https://www.digitalocean.com/).
  * Fork this repository (https://github.com/itu-devops/itu-minitwit-ci) by clicking on the fork button on Github
  * Clone your fork of the repository:

  ```bash
  $ git clone https://github.com/<your_gh_user>/itu-minitwit-ci.git
  $ cd itu-minitwit-ci
  ```

  * Add your Docker Hub credentials to the `Vagrantfile`, that is replace `<your_dockerhub_id>` and `<your_dockerhub_pwd>` on lines 36 and 37 with your login ID and password. **OBS:** Remember to **not push these credentials back to a public repository**.

  * Install the Travis CLI client, which is provided via a Ruby GEM. Make sure you have at least Ruby 2.3.0 (2.6.0 recommended) installed. You can check your Ruby version by running `ruby -v`.
    - To install the Travis CLI client on Linux (and MacOS) run `sudo gem install travis --no-document`.
    - In case you are on a Windows machine run `$ gem install travis`
    - See the [official documentation](https://github.com/travis-ci/travis.rb#installation)
  * To allow the Travis CLI tool to log into your Travis CI account later, create a GitHub Personal Access Token, see the [official documentation](https://github.com/settings/tokens):
    - Give the token a name and select the scopes `repo` and `admin:org`

    ![](images/github_tokens.png)
    ![](images/gh_token_scopes.png)



----

To setup this scenario we have two parts:
- A remote server to which we will deploy our ITU-MiniTwit application and which is provisioned on DigitalOcean using `vagrant`.
- A Travis CI pipeline, which we will use to automate tests, build the application (in Docker images) and deploy them to the server.


![](images/CICD_Setup.png)



----

# Preparation

## 2.) SSH Key Pair

To connect to the server we are going to provision, we will use RSA keys for authentication. We will provide the same SSH keys to the Travis CI pipeline, so that it can automatically deploy new versions on our server.

Now, create a keypair as illustrated below. The `-m "PEM"` sets the format of the generated key pair to a format that is supported by Travis CI.

```bash
$ cd ssh_keys
$ ssh-keygen -m "PEM"
```

<!-- ssh-keygen -t rsa -b 4096 -m "PEM" -->

When prompted for the file to save the key (`Enter file in which to save the key (/home/<your_user>/.ssh/id_rsa)`) type `./ssh_keys/do_ssh_key`. Hit enter three times to accept the other defaults. You can call the SSH key files whatever you want, but the `Vagrantfile` expects the SSH keys to have that specific name. So in case you use another name, adapt the `Vagrantfile` accordingly.


## 2.1.) Register your Public SSH at DigitalOcean

Now, after generating the key pair, log into DigitalOcean and navigate to the security configuration, left bottom under `ACCOUNT` -> `Security`.

Under `SSH keys` click the `Add SSH Key` button and register a `New SSH key` with the name `do_ssh_key`. Paste into the input field the contents of `ssh_keys/do_ssh_key.pub`, which you might receive via: `cat ssh_keys/do_ssh_key.pub` on the command line.



## 2.2.) Add SSH key to Github repository

Add the generated SSH key to your Github repository, so that Travis CI can clone the repository when we run the pipeline. Navigate to the page of the repository on github.com in your browser and click the `Settings` tab:

![](images/add_ssh_key_github.png)

Now click `Deploy keys` and then `Add deploy key`. Set the title to something like "Travis CI pipeline" so that you know who has access through this key. Then paste the contents of the **public** key of the SSH keys we generated earlier (`cat ssh_keys/do_ssh_key.pub`).

![](images/add_deploy_key.png)

Finish by clicking `Add key`.


--------------------

# 3.) Creating a Remote Server

## Vagrant DigitalOcean Plugin

We assume you have `vagrant` and the Vagrant DigitalOcean plugin installed, see [session 3 prep. notes](https://github.com/itu-devops/lecture_notes/blob/master/sessions/session_03/README_PREP.md).


## DigitalOcean Token

To create virtual machines at DigitalOcean with `vagrant` we must generate an authentication token. If you did so already during the last exercise session, you can skip this section. Otherwise, log into DigitalOcean in your browser, then navigate to `API` in the menu on the right, then click on `Generate New Token`. You must give it a name, for example the name of the machine where you use the token.

![](images/do_token.png)

The `Vagrantfile` expects to find your DigitalOcean token in a respective environment variable in your shell environment. For example, you can  add it to your `~/.bashrc` or `~/.zshrc`. The variable must be called: called `DIGITAL_OCEAN_TOKEN`, the syntax for defining such an environment variable in your shell configuration file is:

```bash
export DIGITAL_OCEAN_TOKEN=<your-token>
```

After adding the token you must reload your shell. Either close your current terminal and open a new one or use the `source` command on the shell config file you changed, e.g., `source ~/.bashrc`.


## Starting the Remote Server

Now, you should be able to create the remote VM via `vagrant up`. You can use the below command to ensure that vagrant will use the DigitalOcean provider:

```bash
$ vagrant up --provider=digital_ocean
```

![](images/vagrant_up.png)

Note down the IP of this server as we will need it in a later step. It should be displayed after the server was created.


### `/remote_files`

All files contained in the directory `remote_files` will be synced to the newly provisioned server. Currently, this is only a single `docker-compose.yml` file, which later will be used to deploy our ITU-MiniTwit application automatically.


<!--
When the server has finished initalizing, it use docker-compose file to start minitwtit with the command `docker-compose up -d`. The `up` command actually does a lot of things: first it will check if the images specified in the docker-compose.yml are present, if they are not it will attempt to pull them from `hub.docker.com` or any other private registries it might be signed into. Next the `up` command will check if there are any running conatiners of the images, and if there are none, it will create them, if they are present, but an older version, the images that have a newer version available will be recreated with newer version. If all containers are up to date, then nothing will happen. The `-d` will start the docker containers as `daemons` in the background.

Whenever the `mysql` container is restarted it needs ~20 seconds to initialize, so don't panic if the url shows a mysql error, just wait a moment and reload the page.
-->

### SSH to server

If you need to SSH to remote server you can easily do it through `vagrant` with the `ssh` command:

```bash
$ vagrant ssh
```

You can also do it 'manually' like so:
```bash
$ ssh root@<digital-ocean-machine-ip> -i <path_to/do_ssh_key>
```

------


# Travis CI Pipeline

Now, we will setup the Travis CI pipeline.

##  4.) Configuration

### Sign up for Travis CI

Start by signing up for Travis CI. Navigate with your browser to [`https://travis-ci.com`](https://travis-ci.com) and select `Sign up with Github`.

![](images/travis_signup.png)

Then, you will be taken to the authorization page, confirm the use of the app.

![](images/travis_authorize.png)

You should now be redirected to an empty dashboard.

### Authorize Travis CI

Now, we will setup Travis CI to run a CI/CD pipeline whenever we push commits to our repository. Start by clicking on your profile picture in the upper right corner (make sure to click the image and not the dropdown arrow!) and click `Settings`.

![](images/click_profile.png)

Now, we must authorize the "Github Apps Integration". Click the `Activate Button`.

![](images/travis_activate_app.png)

Then approve.

![](images/travis_app_approve.png)

Now, you should see a list of your repositories. Use the search bar to filter to for the `itu-minitwit-ci` repository and click its name:

![](images/travis_repo_search.png)


#### SSH Key Configuration

For this scenario, we have to share the SSH key in an appropriate format so that Travis CI can clone this repository to build it. We need the `travis` CLI tool to add the SSH key to build from a public repository.

Log into your Travis CI account from the terminal with the `travis` CLI tool (for reproducing this scenario, remember the `--com` option, since Travis has two hosting domains). 

`travis login --com --github-token <YOUR-TOKEN>`

Once you've been authorized (message like `Successfully logged in as <your_gh_username>!`), encrypt your SSH key (remember the `-r` option, so Travis knows which repository you are reffering to):

`travis encrypt-file ssh_keys/do_ssh_key --com -r <your_gh_username>/itu-minitwit-ci`

The above command creates an outpu similar to the following:


openssl aes-256-cbc -K $encrypted_56635d5d55b3_key -iv $encrypted_56635d5d55b3_iv -in do_ssh_key.enc -out ssh_keys/do_ssh_key -d


```
encrypting ssh_keys/do_ssh_key for <your_gh_username>/itu-minitwit-ci
storing result as do_ssh_key.enc
storing secure env variables for decryption

Please add the following to your build script (before_install stage in your .travis.yml, for instance):

    openssl aes-256-cbc -K $encrypted_<key_value>_key -iv $encrypted_<iv_value>_iv -in do_ssh_key.enc -out ssh_keys/do_ssh_key -d

Pro Tip: You can add it automatically by running with --add.

Make sure to add do_ssh_key.enc to the git repository.
Make sure not to add ssh_keys/do_ssh_key to the git repository.
Commit all changes to your .travis.yml.
```

Afterwards, take the values from `<key_value>` and from `<iv_value>` from the above output and store them in the `.travis.yml` file (both marked with `<REPLACE_ME>` in the `.travis.yml` file that you pulled).

Now, add `do_ssh_key.enc` to version control (`git add ssh_keys/do_ssh_key.enc`, `git commit ...`, `git push`, ...).
Do the same with the modified `.travis.yml` file.

Remember to **commit and push** the two updated files to your fork of the repository. 

#### Environment Variables

Next, we have to add some environment variables, scroll to `Environment Variables`, which you can reach under the Settings of the build job for this repository.

For this scenario you must set the following environment variables:

- `DOCKER_USERNAME` username for hub.docker.com
- `DOCKER_PASSWORD` password for username for hub.docker.com
- `MT_USER` the user we will SSH to, default is `root`
- `MT_SERVER` the IP address of the server we created on DigitalOcean, which you noted down earlier.

![](images/added_travis_environment_vars.png)

These are key-value pairs that are substitutes for their actual value when the pipeline runs. They are never printed to any logs, so this is the way to add "secrets" to your pipeline, like login usernames and passwords.

## 5.) `.travis.yml` - A Pipeline's Configuration File

In order to build using Travis CI pipelines, we must add a file to the root of the Github repository called `.travis.yml` that contains the all of the commands to be executed by the pipeline. The nice thing about this being a file in our Git repository is that we can version it along with the rest of our code and keep all of our code and configuration in the same place without having to use any web GUI's - Configuration as Code!

The scenario should already have a sample `.travis.yml` in the repository.

```yaml
os: linux
dist: bionic

language: python
python:
  - 3.7

services:
  - docker  # required, but travis uses older version of docker :(

before_install:
  # Decrypt the git_deploy_key.enc key into /tmp/git_deploy_key
  - openssl aes-256-cbc -K $encrypted_<REPLACE_ME>_key -iv $encrypted_<REPLACE_ME>_iv -in do_ssh_key.enc -out /tmp/git_deploy_key -d
  # Make sure only the current user can read the private key
  - chmod 600 /tmp/git_deploy_key
  # Create a script to return the passphrase environment variable to ssh-add
  - echo 'echo ${SSH_PASSPHRASE}' > /tmp/askpass && chmod +x /tmp/askpass
  # Start the authentication agent
  - eval "$(ssh-agent -s)"
  # Add the key to the authentication agent
  - DISPLAY=":0.0" SSH_ASKPASS="/tmp/askpass" setsid ssh-add /tmp/git_deploy_key </dev/null

install:
  - docker --version  # document the version travis is using

stages:
  - docker_build
  - test
  - deploy

jobs:
  include:
    - stage: docker_build
      name: "build and push docker"
      script:
        - echo "LOGIN"
        - echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin
        - echo "BUILD"
        - docker build -t $DOCKER_USERNAME/minitwitimage:latest . -f Dockerfile-minitwit
        - docker build -t $DOCKER_USERNAME/mysqlimage:latest . -f Dockerfile-mysql
        - docker build -t $DOCKER_USERNAME/flagtoolimage:latest . -f Dockerfile-flagtool
        - echo "PUSH"
        - docker push $DOCKER_USERNAME/minitwitimage:latest
        - docker push $DOCKER_USERNAME/mysqlimage:latest
        - docker push $DOCKER_USERNAME/flagtoolimage:latest

    - stage: test
      name: "run pytest"
      install: skip
      script:
        - docker build -t $DOCKER_USERNAME/minitwittestimage -f Dockerfile-minitwit-tests .
        - yes | docker-compose up -d
        - docker run -it --rm --network=itu-minitwit-network $DOCKER_USERNAME/minitwittestimage

    - stage: deploy
      name: "deploy new version"
      install: skip
      # -o flag to get around "add ip to known hosts prompt"
      script: |
        ssh -o "StrictHostKeyChecking no" ${MT_USER}@${MT_SERVER} \
        "source /root/.bash_profile && \
        cd /vagrant && \
        docker-compose pull && \
        docker-compose up -d && \
        docker pull $DOCKER_USERNAME/flagtoolimage:latest"

```

This pipeline is divided into three stages:
  
  - `docker_build`
    - The build stage will first build our three Docker containers and subsequently push them to `hub.docker.com`.
  - `test`
    - The test stage runs some automated frontend tests on our application, to check that everything is still working. If the test fails the pipeline will abort and alert you that the tests are failing.
  - `deploy`
    - The final stage deploys the new version to our remote server by opening an SSH connection and, which remotely sets-up the environment variables (`source /root/.bash_profile`), pulls the freshly built Docker images from hub.docker.com (`docker-compose pull`), and finally updates the running containers to the new version (`docker-compose up -d`).

Note, that each stage is executed in a freshly provisioned VM, so no state carries over from stage to stage, unless you explicitly tell Travis CI to do so.

## Trigger Pipeline

Now we are ready to trigger the pipeline. If all of the above went well, a new version of _ITU-MiniTwit_ should be build, tested, delivered, and deployed on every new commit to the repository.

![](images/triggered_pipeline.png)

---


# Credits

This scenario exists only due to the hard work of the TAs:
  * [Zander](https://github.com/zanderhavgaard)
  * [Christoffer](https://github.com/ChristofferNissen)
  * [Michal](https://github.com/tschesky)

---


For some more details on the docker images see the file `readme_dockerized.md`
