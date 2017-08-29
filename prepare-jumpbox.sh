#!/bin/bash

set -e

function add_users_to_jumpbox() {
  users=`echo $USERS | tr ',' '\n'`
  echo "Adding users to jumpbox"
  for user in $users; do
    adduser $user --gecos "" --disabled-password
    echo -e "$user:$user" | chpasswd
    cp -r /home/ubuntu/.ssh/ /home/$user/.ssh/
    chown -R $user:$user /home/$user/.ssh/
    echo -e "$user ALL=NOPASSWD: ALL" >> /etc/sudoers
  done
}

cd /home/ubuntu
(("$?" == "0")) ||
  fail "Could not find HOME folder, terminating install."

release=$(cat /etc/*release | tr -d '\n')
case "${release}" in
  (*Ubuntu*|*Debian*)
    # ...first add the Cloud Foundry Foundation public key and package repository to your system
    wget -q -O - https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | apt-key add -
    echo "deb http://packages.cloudfoundry.org/debian stable main" | tee /etc/apt/sources.list.d/cloudfoundry-cli.list
    # ...then, update your local package index, then finally install the cf CLI
    apt-get update -yq
    apt-get install -yq aptitude
    aptitude -yq install git unzip socat build-essential zlibc zlib1g-dev ruby \
    ruby-dev python-dev python-pip openssl libxslt-dev libxslt1-dev libpq-dev \
    libmysqlclient-dev libxml2-dev lib libssl-dev libreadline6 \
    libreadline6-dev libyaml-dev libsqlite3-dev sqlite3 ldap-utils cf-cli

    # Ubuntu 14.04 has older jq which lacks excellent -e argument, we want 1.5
    # So force jq to be 1.5 by grabbing executable directly, not asking for jq above
    # Remove this and include above when we get 1.5 jq with later ubuntu
    wget -O jq https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
    chmod +x /home/ubuntu/jq
    mv /home/ubuntu/jq /usr/local/bin/jq
    ;;
  (*centos*|*RedHat*|*Amazon*)
    yum update -y
    yum install -y epel-release
    yum install -y git unzip xz tree rsync openssl openssl-devel zlib zlib-devel \
    libevent libevent-devel readline readline-devel cmake ntp htop wget tmux gcc g++ \
    autoconf pcre pcre-devel vim-enhanced python-devel python-pip ruby ruby-devel \
    mysql-devel postgresql-devel postgresql-libs sqlite-devel libxslt-devel libxml2-devel \
    patch yajl-ruby openldap-clients jq
    ;;
esac

USERS=""
while getopts ":u:" opt; do
  case $opt in
    u)
      USERS=$OPTARG
      ;;
    \?)
      echo "Usage: $0 -u <comma delimited list of users>" 1>&2
      exit 1;
      ;;
  esac
done

if [ -z "${USERS}" ]; then
  echo "Not adding users to Jumpbox as no users flag was provided" 1>&2
fi

# Run the add_users_to_jumpbox function defined above
add_users_to_jumpbox

# Install the AWS CLI
pip install awscli

# Install bosh-init if not already installed
if [[ ! -f /usr/local/bin/bosh-init ]]; then
  echo "bosh-init not installed, now installing!"
  wget https://s3.amazonaws.com/bosh-init-artifacts/bosh-init-0.0.103-linux-amd64
  chmod +x /home/ubuntu/bosh-init-*
  mv /home/ubuntu/bosh-init-* /usr/local/bin/bosh-init
fi

if [[ ! -f /usr/local/bin/spiff ]]; then
  echo "Spiff not installed, now installing!"
  wget https://github.com/cloudfoundry-incubator/spiff/releases/download/v1.0.8/spiff_linux_amd64.zip
  unzip /home/ubuntu/spiff_linux_amd64.zip
  mv /home/ubuntu/spiff /usr/local/bin/spiff
  rm /home/ubuntu/spiff_linux_amd64.zip
fi

if [[ ! -f /usr/local/bin/spruce ]]; then
  echo "Spruce not installed, now installing!"
  wget https://github.com/geofffranks/spruce/releases/download/v1.10.0/spruce-linux-amd64
  chmod +x /home/ubuntu/spruce-linux-amd64
  mv /home/ubuntu/spruce-linux-amd64 /usr/local/bin/spruce
fi

if [[ ! -f /usr/local/bin/yaml2json ]]; then
  echo "yaml2json not installed, now installing!"
  wget -O yaml2json https://github.com/bronze1man/yaml2json/blob/master/builds/linux_amd64/yaml2json?raw=true
  chmod +x /home/ubuntu/yaml2json
  mv /home/ubuntu/yaml2json /usr/local/bin/yaml2json
fi

if [[ ! -f /usr/local/bin/vault ]]; then
  echo "vault not installed, now installing!"
  wget https://releases.hashicorp.com/vault/0.7.3/vault_0.7.3_linux_amd64.zip?_ga=2.97395095.960141617.1497889399-984487553.1495566044
  unzip /home/ubuntu/vault_*
  chmod +x /home/ubuntu/vault
  mv /home/ubuntu/vault /usr/local/bin/vault
  rm /home/ubuntu/vault_*
fi

if [[ ! -f /usr/local/bin/fly ]]; then
  echo "fly not installed, now installing!"
  wget -O fly https://github.com/concourse/concourse/releases/download/v3.2.1/fly_linux_amd64
  chmod +x /home/ubuntu/fly
  mv /home/ubuntu/fly /usr/local/bin/fly
fi

if [[ ! -f /usr/local/bin/bosh-v2 ]]; then
  echo "bosh-v2 not installed, now installing!"
  wget -O bosh-v2 https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-2.0.26-linux-amd64
  chmod +x /home/ubuntu/bosh-v2
  mv /home/ubuntu/bosh-v2 /usr/local/bin/bosh-v2
fi

# Install RVM
if [[ ! -d "/usr/local/rvm" ]]; then
  cd /usr/local/
  curl -sSL https://rvm.io/mpapis.asc | gpg --import -
  curl -sSL https://get.rvm.io | bash -s stable
fi
cd /
if [[ ! "$(ls -A /usr/local/rvm/environments)" ]]; then
  /usr/local/rvm/bin/rvm install ruby-2.1
fi
if [[ ! -d "/usr/local/rvm/environments/default" ]]; then
  /usr/local/rvm/bin/rvm alias create default 2.1
fi
/usr/local/rvm/bin/rvm use 2.1 --default
# Install BOSH_CLI and UAAC
gem install bosh_cli --no-ri --no-rdoc

gem install cf-uaac --no-ri --no-rdoc

su - ubuntu
source /etc/profile.d/rvm.sh

echo "Script completed"
echo "NOTE - .profile updated for rvm, get new login shell or source it to get env"
echo 0
reboot
