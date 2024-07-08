#!/bin/bash

# Change to the root home directory
cd /root

# Install necessary dependencies to build Cisco NSO 
echo "Updating and installing necessary dependencies..."
apt-get update && apt-get install -y vim \
tree \
git \
openssh-client \
openssl \
libexpat1 \
libxml2-utils \
libxml2 \
xsltproc \
build-essential \
ant \
net-tools 

# Install Java JDK
apt install -y openjdk-17-jdk openjdk-17-jre

# Install Python3 and PIP (optional)
echo "Installing Python3 and PIP..."
apt-get update \
&& apt-get install -y python3-pip python3-dev python3-setuptools \
&& cd /usr/local/bin \
&& ln -s /usr/bin/python3 python \
&& pip3 install --upgrade pip

# Generate SSH Key pair if it does not exist
if [ ! -f "$HOME/.ssh/id_rsa" ]; then
    echo "Generating SSH key pair..."
    ssh-keygen -t rsa -C "$HOSTNAME" -f "$HOME/.ssh/id_rsa" -P "" && cat ~/.ssh/id_rsa.pub
else
    echo "SSH key pair already exists."
fi

# Make the NSO installer executable
if [ ! -f ~/nso-6.3.linux.x86_64.installer.bin ]; then
    echo "NSO installer not found!"
    exit 1
fi
chmod +x ~/nso-6.3.linux.x86_64.installer.bin

# Install Cisco NSO as local install
if [ ! -d "$HOME/nso-6.3" ]; then
    echo "Setting up Cisco NSO Installation ..."
    mkdir -p $HOME/nso-6.3
fi

sh ~/nso-6.3.linux.x86_64.installer.bin $HOME/nso-6.3 --local-install
echo "Cisco NSO 6.3 Local Installation Completed."
export NCS_DIR=${HOME}/nso-6.3 
echo ${NCS_DIR}

# Update ~/.bashrc with 'source $HOME/nso-6.3/ncsrc'
if ! grep -q "source $NCS_DIR/ncsrc" ~/.bashrc; then
    echo "Updating ~/.bashrc to source ncsrc..."
    echo "source $NCS_DIR/ncsrc" >> ~/.bashrc
fi

# Source ncsrc
source $NCS_DIR/ncsrc

# Create an instance of ncs/nso with ncs-setup
if [ ! -d "$HOME/ncs-instance" ]; then
    echo "Setting up NSO instance..."
    mkdir -p $HOME/ncs-instance
fi

# Create NCS_RUN_DIR environmental variable
export NCS_RUN_DIR=${HOME}/ncs-instance
echo "export NCS_RUN_DIR=${HOME}/ncs-instance" >> ~/.bashrc
echo ${NCS_RUN_DIR}

# Copy NEDs to NSO packages directory
cp -r "$HOME/neds"/* "$NCS_DIR/packages/neds/"

# ncs-setup --dest $HOME/ncs-instance or --dest ${NCS_RUN_DIR} 
ncs-setup --package ${NCS_DIR}/packages/neds/cisco-asa-cli-6.18 \
--package ${NCS_DIR}/packages/neds/cisco-ios-cli-6.106 \
--package ${NCS_DIR}/packages/neds/cisco-iosxr-cli-7.55 \
--package ${NCS_DIR}/packages/neds/cisco-nx-cli-5.25 \
--dest ${NCS_RUN_DIR}  

# Start ncs/nso instance in the foreground
echo "Starting NSO instance..."
cd $HOME/ncs-instance
ncs
