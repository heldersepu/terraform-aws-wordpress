#!/usr/bin/env bash

TRAVISCI_LINUX_IPS='nat.gce-us-central1.travisci.net'
#TRAVISCI_GLOBAL_IPS='nat.travisci.net'
TRAVISCI_IPS="$(dig +short $TRAVISCI_LINUX_IPS | awk '{printf $1"/32,"}' ORS=" ")"

# Add binaries to bin directory
[ ! -d "$HOME/vendor/bin" ] && mkdir -p $HOME/vendor/bin
export PATH=$PATH:$HOME/vendor/bin:$HOME/vendor/aws-sdk/bin

# Install AWS CLI
curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
sudo apt-get -y install unzip
unzip awscli-bundle.zip
sudo ./awscli-bundle/install -i $HOME/vendor/aws-sdk -b $HOME/vendor/aws-sdk/bin/aws
$HOME/vendor/aws-sdk/bin/aws --version

# Authenticate
# Make a directory to contain the key
[ ! -d "./test/assets" ] && mkdir -p test/assets

# Generate a 2048 bit RSA key with a blank passphrase in the directory
# Add "-m pem" if running from OSX mojave
ssh-keygen -b 2048 -C "Kitchen-Terraform AWS" -f test/assets/wordpress -N "" -t rsa

which terraform
# Run test
bundle exec kitchen test --destroy always
KITCHEN_EXIT_CODE=$? #Save exit code to exit with it, but still clean up no matter the code
printf "%sPATH:\n" $PATH
if [ $KITCHEN_EXIT_CODE -ne "0" ]
then
printf "***************\nKitchen Error Log"

cat .kitchen/logs/test-suite-centos.log
fi

exit $KITCHEN_EXIT_CODE