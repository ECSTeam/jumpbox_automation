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

# Install jq
 if [[ ! -f /usr/local/bin/jq ]]; then
  echo "jq not installed, now installing!"
  wget -q -O /usr/local/bin/jq $(curl -s https://api.github.com/repos/stedolan/jq/releases/latest | grep "browser_download_url" | grep "jq-linux64" | cut -d '"' -f4)
  chmod +x /usr/local/bin/jq
fi

# Install bosh-init if not already installed
if [[ ! -f /usr/local/bin/bosh-init ]]; then
  echo "bosh-init not installed, now installing!"
  wget -O /usr/local/bin/bosh-init https://s3.amazonaws.com/bosh-init-artifacts/bosh-init-"$(curl -s https://api.github.com/repos/cloudfoundry/bosh-init/releases/latest | jq -r '.name' | tr -d 'v')"-linux-amd64
  chmod +x /usr/local/bin/bosh-init
fi

if [[ ! -f /usr/local/bin/spiff ]]; then
  echo "Spiff not installed, now installing!"
  wget -q -O spiff.zip "$(curl -s https://api.github.com/repos/cloudfoundry-incubator/spiff/releases/latest | jq -r '.assets[] | select(.name == "spiff_linux_amd64.zip") | .browser_download_url')" 
  unzip spiff.zip
  mv spiff /usr/local/bin/
  rm spiff.zip
fi

if [[ ! -f /usr/local/bin/spruce ]]; then
  echo "Spruce not installed, now installing!"
  wget -q -O /usr/local/bin/spruce "$(curl -s https://api.github.com/repos/geofffranks/spruce/releases/latest | jq --raw-output '.assets[] | .browser_download_url' | grep linux | grep -v zip)"
  chmod +x /usr/local/bin/spruce
fi

if [[ ! -f /usr/local/bin/yaml2json ]]; then
  echo "yaml2json not installed, now installing!"
  wget -O /usr/local/bin/yaml2json https://github.com/bronze1man/yaml2json/blob/master/builds/linux_amd64/yaml2json?raw=true
  chmod +x /usr/local/bin/yaml2json
fi

if [[ ! -f /usr/local/bin/vault ]]; then
  echo "vault not installed, now installing!"
  wget -q -O vault.zip $(curl -s https://www.vaultproject.io/downloads.html | grep linux_amd | awk -F "\"" '{print$2}')
  unzip vault.zip
  mv vault /usr/local/bin/
  rm vault.zip
fi

if [[ ! -f /usr/local/bin/fly ]]; then
  echo "fly not installed, now installing!"
  wget -q -O /usr/local/bin/fly "$(curl -s https://api.github.com/repos/concourse/fly/releases/latest | jq --raw-output '.assets[] | .browser_download_url' | grep linux)"
  chmod +x /usr/local/bin/fly
fi

if [[ ! -f /usr/local/bin/bosh2 ]]; then
  echo "bosh2 not installed, now installing!"
  wget -q -O /usr/local/bin/bosh2 https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-$(curl -s https://api.github.com/repos/cloudfoundry/bosh-cli/releases/latest | jq -r '.name' | tr -d 'v')-linux-amd64
  chmod +x /usr/local/bin/bosh2
fi

# Install RVM
if [[ ! -d "/usr/local/rvm" ]]; then
  cd /usr/local/
  curl -sSL https://rvm.io/mpapis.asc | gpg --import -
  curl -sSL https://get.rvm.io | bash -s stable
fi
cd /
if [[ ! "$(ls -A /usr/local/rvm/environments)" ]]; then
  /usr/local/rvm/bin/rvm install ruby-2.3.0
fi
if [[ ! -d "/usr/local/rvm/environments/default" ]]; then
  /usr/local/rvm/bin/rvm alias create default 2.3.0
fi
/usr/local/rvm/bin/rvm use 2.3.0 --default
# Install BOSH_CLI and UAAC
gem install bosh_cli --no-ri --no-rdoc

gem install cf-uaac --no-ri --no-rdoc

# su - ubuntu
source /etc/profile.d/rvm.sh

echo "Script completed"
echo "NOTE - .profile updated for rvm, get new login shell or source it to get env"
echo 0
reboot
