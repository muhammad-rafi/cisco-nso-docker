# Base Linux (Ubuntu 20.04) is used for the Cisco NSO local install
FROM ubuntu:20.04
USER root 

# File author and maintainer information
MAINTAINER Muhammad Rafi

# Metadata for this image
LABEL image.authors="murafi@cisco.com" image.verions="0.1"

# Update and install required packages to build Cisco NSO 
RUN apt-get update && apt-get install -y \
        openssh-client \ 
        openssl \
        libexpat1 \
        libxml2-utils \
        libxml2 \
        default-jdk \
        ant \
        net-tools 

# Add another user if you don't prefer to use root user.
#RUN useradd -rm -d /home/mrafi -s /bin/bash -g root -G sudo -u 1001 mrafi
#USER mrafi
#WORKDIR /home/mrafi

# Working directory in use to perform the further actions (DO NOT USE IN PROD ENV ! )
WORKDIR /root

# Copy NSO installer.bin file from the current directory to the /root directory 
COPY ${pwd}/nso-5.5.linux.x86_64.installer.bin .

# Generate SSH Key pair
RUN ssh-keygen -t rsa -C "$HOSTNAME" -f "$HOME/.ssh/id_rsa" -P "" && cat ~/.ssh/id_rsa.pub

# Install Cisco NSO as local install
RUN sh nso-5.5.linux.x86_64.installer.bin --local-install ~/nso-5.5

# Delete the nso installer after the container is built
RUN rm -f nso-5.5.linux.x86_64.installer.bin

# Update ~/.bashrc with 'source $HOME/nso-5.5/ncsrc'
RUN echo "source $HOME/nso-5.5/ncsrc" >> ~/.bashrc

# RUN source $HOME/nso-5.5/ncsrc
SHELL ["/bin/bash", "-c", "source $HOME/nso-5.5/ncsrc"]

# Copy NSO packages to the container package directory
COPY ${pwd}/packages/ncs-5.5-cisco* /root/nso-5.5/packages/neds/

# Expose port required for Cisco NSO Server
EXPOSE 2022 2024 8080 8888

# To build Cisco NSO container and run this image 
# $ docker build -t cisco-nso-dev:0.1 .
# $ docker run --name cisco-nso-dev -p 2024:2024 -p8080:8080 -itd cisco-nso-dev:0.1

# Once nso container is built, go to the contrain and create an Cisco NSO instance 'ncs-run'
# $ ncs-setup --dest $HOME/ncs-run

# Go to the nso instance 'ncs-run' directory and start Cisco NSO instance
# $ ncs-setup --dest $HOME/ncs-run
# $ cd ncs-run 

# Finally start the Cisco NSO instance 
# $ ncs

# Verify instance has been started
# $ ncs --status | grep status