#!/bin/bash

set -e

# Setup so that ssh-copy-id can work correctly!
mkdir /iac/ssh-keys
mkdir ~/.ssh

# Install any needed packages
apt-get update -yq
apt-get install -yq dialog apt-utils curl unzip wget perl apt-transport-https

#Add the Cloud Foundry Foundation public key and package repository to your system
wget -q -O - https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | apt-key add -
echo "deb http://packages.cloudfoundry.org/debian stable main" | tee /etc/apt/sources.list.d/cloudfoundry-cli.list

apt-get update -yq
#Install base operating environment
apt-get install -yq vim git socat build-essential zlibc zlib1g-dev ruby \
ruby-dev python-dev python-pip openssl libxslt-dev libxslt1-dev libpq-dev \
libmysqlclient-dev libxml2-dev libssl-dev libreadline6 \
libreadline6-dev libyaml-dev libsqlite3-dev sqlite3 ldap-utils cf-cli \
sshpass openssh-client

#Get the latest Terraform
echo "Terraform 0.11.1 now installing!"
wget https://releases.hashicorp.com/terraform/0.11.1/terraform_0.11.1_linux_amd64.zip
unzip terraform_0.11.1_linux_amd64.zip terraform
mv terraform /usr/local/bin/

# Check to see if there is a pip update available
pip install --upgrade pip
# Install the AWS CLI
pip install awscli

# Install jq
echo "jq now installing!"
wget -q -O /usr/local/bin/jq $(curl -s https://api.github.com/repos/stedolan/jq/releases/latest | grep "browser_download_url" | grep "jq-linux64" | cut -d '"' -f4)
chmod +x /usr/local/bin/jq

# Install bosh-init if not already installed
echo "bosh-init now installing!"
wget -O /usr/local/bin/bosh-init https://s3.amazonaws.com/bosh-init-artifacts/bosh-init-"$(curl -s https://api.github.com/repos/cloudfoundry/bosh-init/releases/latest | jq -r '.name' | tr -d 'v')"-linux-amd64
chmod +x /usr/local/bin/bosh-init

echo "Spiff now installing!"
wget -q -O spiff.zip "$(curl -s https://api.github.com/repos/cloudfoundry-incubator/spiff/releases/latest | jq -r '.assets[] | select(.name == "spiff_linux_amd64.zip") | .browser_download_url')"
unzip spiff.zip
mv spiff /usr/local/bin/
rm spiff.zip

echo "Spruce now installing!"
wget -q -O /usr/local/bin/spruce "$(curl -s https://api.github.com/repos/geofffranks/spruce/releases/latest | jq --raw-output '.assets[] | .browser_download_url' | grep linux | grep -v zip)"
chmod +x /usr/local/bin/spruce

echo "yaml2json now installing!"
wget -O /usr/local/bin/yaml2json https://github.com/bronze1man/yaml2json/blob/master/builds/linux_amd64/yaml2json?raw=true
chmod +x /usr/local/bin/yaml2json

echo "vault now installing!"
wget -q -O vault.zip $(curl -s https://www.vaultproject.io/downloads.html | grep linux_amd | awk -F "\"" '{print$2}')
unzip vault.zip
mv vault /usr/local/bin/
rm vault.zip

echo "fly now installing!"
wget -q -O /usr/local/bin/fly "$(curl -s https://api.github.com/repos/concourse/fly/releases/latest | jq --raw-output '.assets[] | .browser_download_url' | grep linux)"
chmod +x /usr/local/bin/fly

echo "bosh2 now installing!"
wget -q -O /usr/local/bin/bosh2 https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-$(curl -s https://api.github.com/repos/cloudfoundry/bosh-cli/releases/latest | jq -r '.name' | tr -d 'v')-linux-amd64
chmod +x /usr/local/bin/bosh2

cd /usr/local/
curl -sSL https://rvm.io/mpapis.asc | gpg --import -
curl -sSL https://get.rvm.io | bash -s stable

cd /
/usr/local/rvm/bin/rvm install ruby-2.3.0

/usr/local/rvm/bin/rvm alias create default 2.3.0
/usr/local/rvm/bin/rvm use 2.3.0 --default

# Install BOSH_CLI and UAAC
gem install bosh_cli --no-ri --no-rdoc

gem install cf-uaac --no-ri --no-rdoc

# su - ubuntu
source /etc/profile.d/rvm.sh
