# Cisco-nso-docker

## Introduction

The purpose of writing this document is to install Cisco NSO on a docker container rather than using a dedicated VM. There is an official [Cisco NSO docker](https://github.com/NSO-developer/nso-docker) image available if you like to use it but I have had few issues working with that image, so I thought to bring up mine own. 

There are two types of NSO installation available Local vs System, I have created my docker file based on the Local as Local Install is used for development, lab, and evaluation purposes. This is **not** meant to be used for production. 

Instead of writing the step-by-step process required for Cisco NSO local install, I have created two files `Dockerfile` and `Makefile` and they will install and run the docker container respectively. To see the Local Install process, please check out this [link]( https://developer.cisco.com/docs/nso/#!getting-and-installing-nso/installation).

Lastly, I have created this container on my DevNet Expert Candidate Workstation (CWS) Ubunut 20.04 for my DevNet Expert studies, but you can build this on other operating systems running docker.

## Installation 

Before you start, you need to make sure you have Cisco NSO installer and Network Element Drivers (NEDs) downloaded already from [Cisco Developer website]( https://developer.cisco.com/docs/nso/#!getting-and-installing-nso/download-your-nso-free-trial-installer-and-cisco-neds). Latest version for both is 5.7 at the time of writing this document. However, I used 5.5 in this document. 

**List the currently available docker images**
```bash
(main) expert@expert-cws:~$ docker image ls 
REPOSITORY   TAG          IMAGE ID       CREATED        SIZE
debian       buster       8fa7d0c3e99c   12 days ago    114MB
ubuntu       20.04        53df61775e88   3 weeks ago    72.8MB
python       3.9-alpine   e49e2f1d4108   4 months ago   48.4MB
python       3.9-slim     f565a9e996f5   4 months ago   122MB
python       <none>       ae3c4906b72c   5 months ago   122MB
python       <none>       21a7e8111dc2   5 months ago   45.1MB
python       <none>       3ba8c1c68e98   6 months ago   122MB
python       <none>       8c034acf745b   6 months ago   45.2MB
```
**Check the running docker containers**
```bash
(main) expert@expert-cws:~ $ docker ps -a
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```
**Download or clone the files from this repository and place them in the folder where you like to build and run the contrainer from, I have used `nso` folder available in CWS.**

```bash 
(main) expert@expert-cws:~/nso$ ls -l
total 187532
-rw-rw-r-- 1 expert expert      2171 May 23 23:48 Dockerfile
-r--r--r-- 1 expert expert       364 Mar  8 17:00 INSTALL_NSO_README
-rw-rw-r-- 1 expert expert       236 May 23 19:09 Makefile
-rwxr-xr-x 1 expert expert 192008887 May 21 13:04 nso-5.5.linux.x86_64.installer.bin
drwxrwxr-x 2 expert expert      4096 May 23 12:28 packages
```
You may notice that I have `nso-5.5.linux.x86_64.installer.bin` in my `nso` directory, however, when you downloaded the installer, it has *.signed.bin extention. This is becuase after dowloading the NSO installer and NEDs, we need to extract them. 
To extract the NSO installer 
```bash 
sh nso-5.5.linux.x86_64.signed.bin 

 # Output
 Unpacking...
 Verifying signature...
 Downloading CA certificate from http://www.cisco.com/security/pki/certs/crcam2.cer ...
 Successfully downloaded and verified crcam2.cer.
 Downloading SubCA certificate from http://www.cisco.com/security/pki/certs/innerspace.cer ...
 Successfully downloaded and verified innerspace.cer.
 Successfully verified root, subca and end-entity certificate chain.
 Successfully fetched a public key from tailf.cer.
 Successfully verified the signature of nso-5.5.linux.x86_64.installer.bin using tailf.cer
 ```
 This will generate the folloiwng files, however you may delete all of them except installer binary file (nso-5.5.darwin.x86_64.installer.bin)
 ```bash
README.signature
cisco_x509_verify_release.py
cisco_x509_verify_release.py3
nso-5.5.linux.x86_64.installer.bin 
nso-5.3.linux.x86_64.installer.bin.signature
nso-5.5.linux.x86_64.signed.bin
tailf.cer
 ```
 For unpacking the NEDs, we will see it later in the section but they exist in the `packages` folder.
 ```bash
 (main) expert@expert-cws:~/nso$ ls -l packages/
total 65556
-rw-r--r-- 1 expert expert 57809612 Feb  5  2021 ncs-5.5-cisco-ios-6.69.tar.gz
-rw-r--r-- 1 expert expert  9316936 Jan 13  2021 ncs-5.5-cisco-nx-5.21.tar.gz
(main) expert@expert-cws:~/nso$ 
```
**Build a new Docker image with the Dockerfile in the `nso` directory**
```bash 
(main) expert@expert-cws:~/nso$ docker build -t cisco-nso-dev:0.1 .
Sending build context to Docker daemon  259.1MB
Step 1/14 : FROM ubuntu:20.04
 ---> 53df61775e88
Step 2/14 : USER root
 ---> Running in f21b8de61c97
Removing intermediate container f21b8de61c97
 ---> 5eb1e887d4a7
Step 3/14 : MAINTAINER Muhammad Rafi
 ---> Running in f34175e5c29b
Removing intermediate container f34175e5c29b
 ---> 16049935c46b
Step 4/14 : LABEL image.authors="murafi@cisco.com" image.verions="0.1"
 ---> Running in da3dd6333325
Removing intermediate container da3dd6333325
 ---> 1c80888cc0e1
Step 5/14 : RUN apt-get update && apt-get install -y         openssh-client         openssl         libexpat1         default-jdk         ant         net-tools
 ---> Running in 97a7dd0da219

Output omitted ..
Step 9/14 : RUN sh nso-5.5.linux.x86_64.installer.bin --local-install ~/nso-5.5
 ---> Running in 4960ae46877f
INFO  Using temporary directory /tmp/ncs_installer.6 to stage NCS installation bundle
INFO  Unpacked ncs-5.5 in /root/nso-5.5
INFO  Found and unpacked corresponding DOCUMENTATION_PACKAGE
INFO  Found and unpacked corresponding EXAMPLE_PACKAGE
INFO  Found and unpacked corresponding JAVA_PACKAGE
INFO  Generating default SSH hostkey (this may take some time)
INFO  SSH hostkey generated
INFO  Environment set-up generated in /root/nso-5.5/ncsrc
INFO  NSO installation script finished
INFO  Found and unpacked corresponding NETSIM_PACKAGE
INFO  NCS installation complete

Removing intermediate container 4960ae46877f
 ---> f75fb2c32d01
Step 10/14 : RUN rm -f nso-5.5.linux.x86_64.installer.bin
 ---> Running in 38311d4e0b5c
Removing intermediate container 38311d4e0b5c
 ---> 38467349fd3f
Step 11/14 : RUN echo "source $HOME/nso-5.5/ncsrc" >> ~/.bashrc
 ---> Running in ee6b9ccbc078
Removing intermediate container ee6b9ccbc078
 ---> dcc4aed78b05
Step 12/14 : SHELL ["/bin/bash", "-c", "source $HOME/nso-5.5/ncsrc"]
 ---> Running in dc0fcff361e6
Removing intermediate container dc0fcff361e6
 ---> 30688ce6126a
Step 13/14 : COPY ${pwd}/packages/ncs-5.5-cisco* /root/nso-5.5/packages/neds/
 ---> 7dafa1f3c2e1
Step 14/14 : EXPOSE 2022 2024 8080 8888
 ---> Running in 93c710e099c8
Removing intermediate container 93c710e099c8
 ---> c600427e2bcf
Successfully built c600427e2bcf
Successfully tagged cisco-nso-dev:0.1
```
**Verify `cisco-nso-dev` image has been created with the `0.1` version tag**
```bash
(main) expert@expert-cws:~/nso$ docker image ls
REPOSITORY      TAG          IMAGE ID       CREATED         SIZE
cisco-nso-dev   0.1          c600427e2bcf   7 minutes ago   1.46GB
debian          buster       8fa7d0c3e99c   12 days ago     114MB
ubuntu          20.04        53df61775e88   3 weeks ago     72.8MB
python          3.9-alpine   e49e2f1d4108   4 months ago    48.4MB
python          3.9-slim     f565a9e996f5   4 months ago    122MB
python          <none>       ae3c4906b72c   5 months ago    122MB
python          <none>       21a7e8111dc2   5 months ago    45.1MB
python          <none>       3ba8c1c68e98   6 months ago    122MB
python          <none>       8c034acf745b   6 months ago    45.2MB
(main) expert@expert-cws:~/nso$ 
```
Next step is to build a container with the image we have created in the previous step, simply run `make run` command and it will create a container in detached mode. 
```bash
(main) expert@expert-cws:~/nso$ make run
docker run -itd --name cisco-nso-dev \
                   -p 2024:2024 \
                   -p 8080:8080 \
                   cisco-nso-dev:0.1
63f8d1977f88122b136065cf0914d9e38e076331d23dc314dd0b6ac8d56f9ccf
```
Verify container has been built and it is up and running.
```bash
(main) expert@expert-cws:~/nso$ docker ps -a
CONTAINER ID   IMAGE               COMMAND   CREATED         STATUS         PORTS                                                                                                      NAMES
63f8d1977f88   cisco-nso-dev:0.1   "bash"    7 seconds ago   Up 6 seconds   0.0.0.0:2024->2024/tcp, :::2024->2024/tcp, 2022/tcp, 8888/tcp, 0.0.0.0:8080->8080/tcp, :::8080->8080/tcp   cisco-nso-dev
```
**Now, login to the container via `docker exec` command and create a nso instance***
```bash
docker exec -it 63f8d1977f88 bash
```
Verify following required packages are installed before proceeed 
```bash
root@63f8d1977f88:~# java -version
openjdk version "11.0.15" 2022-04-19
OpenJDK Runtime Environment (build 11.0.15+10-Ubuntu-0ubuntu0.20.04.1)
OpenJDK 64-Bit Server VM (build 11.0.15+10-Ubuntu-0ubuntu0.20.04.1, mixed mode, sharing)
root@63f8d1977f88:~# ant -version
Apache Ant(TM) version 1.10.7 compiled on October 24 2019
root@63f8d1977f88:~# 
```
If you want to create a nso instance without any ‘ned’, you can follow the below commands 
```bash
source $HOME/nso-5.5/ncsrc
ncs-setup --dest $HOME/ncs-run
cd ncs-run 
ncs 
```
If you want to create a nso instance with the specific ‘neds’, you can follow the below Method (I will be showing here only this method) 

But before you create a nso instance, you need to extract the ‘neds’ in the container's folder `nso-5.5/packages/neds`, see the files ending with `tar.gz`
```bash
root@63f8d1977f88:~/nso-5.5/packages/neds# ls -l
total 65596
drwxr-xr-x 8 root root     4096 Dec 21  2020 a10-acos-cli-3.0
drwxr-xr-x 7 root root     4096 Dec 21  2020 alu-sr-cli-3.4
drwxr-xr-x 8 root root     4096 Dec 21  2020 cisco-asa-cli-6.6
drwxr-xr-x 7 root root     4096 Dec 21  2020 cisco-ios-cli-3.0
drwxr-xr-x 7 root root     4096 Dec 21  2020 cisco-ios-cli-3.8
drwxr-xr-x 8 root root     4096 Dec 21  2020 cisco-iosxr-cli-3.0
drwxr-xr-x 8 root root     4096 Dec 21  2020 cisco-iosxr-cli-3.5
drwxr-xr-x 8 root root     4096 Dec 21  2020 cisco-nx-cli-3.0
drwxr-xr-x 8 root root     4096 Dec 21  2020 dell-ftos-cli-3.0
drwxr-xr-x 5 root root     4096 Dec 21  2020 juniper-junos-nc-3.0
-rw-r--r-- 1 root root 57809612 Feb  5  2021 ncs-5.5-cisco-ios-6.69.tar.gz
-rw-r--r-- 1 root root  9316936 Jan 13  2021 ncs-5.5-cisco-nx-5.21.tar.gz
root@63f8d1977f88:~/nso-5.5/packages/neds# 
```
**Extracting the NEDs**
```bash
root@63f8d1977f88:~/nso-5.5/packages/neds# tar -zxvf ncs-5.5-cisco-ios-6.69.tar.gz
root@63f8d1977f88:~/nso-5.5/packages/neds# tar -zxvf ncs-5.5-cisco-nx-5.21.tar.gz
```
I am omitting the output, but there will be extraction output, once extracted, you will see the below folders are created in this directory.
```bash
root@63f8d1977f88:~/nso-5.5/packages/neds# ls -l | grep cisco-ios-cli-6.69
drwxr-xr-x 8 9001 users     4096 Feb  4  2021 cisco-ios-cli-6.69
root@63f8d1977f88:~/nso-5.5/packages/neds# 

root@63f8d1977f88:~/nso-5.5/packages/neds# ls -l | grep cisco-nx-cli-5.21 
drwxr-xr-x 9 9001 users     4096 Jan 12  2021 cisco-nx-cli-5.21
root@63f8d1977f88:~/nso-5.5/packages/neds# 

```
You can safely delete the `.tar.gz` files
```bash
root@63f8d1977f88:~/nso-5.5/packages/neds# rm -f ncs-5.5-cisco-ios-6.69.tar.gz ncs-5.5-cisco-nx-5.21.tar.gz
root@63f8d1977f88:~/nso-5.5/packages/neds#
```
Finally go back to the root folder and run the following commands to create a nso instance with the specific NEDs. 

Here I am creating a nso instance with the following NEDs.
cisco-ios-cli-6.69
cisco-nx-cli-5.21
```bash
root@63f8d1977f88:~# source $HOME/nso-5.5/ncsrc
root@63f8d1977f88:~# ncs-setup --package ~/nso-5.5/packages/neds/cisco-ios-cli-6.69 \
>    --package ~/nso-5.3/packages/neds/cisco-nx-cli-5.21 \
>    --dest ncs-instance
root@63f8d1977f88:~# 
root@63f8d1977f88:~# cd ncs-instance/
root@63f8d1977f88:~/ncs-instance# ncs
root@63f8d1977f88:~/ncs-instance# 
```

**Verify the NCS service has been started and check the NCS version**
```bash
root@63f8d1977f88:~/ncs-instance# ncs --status | grep status
status: started
        db=running id=33 priority=1 path=/ncs:devices/device/live-status-protocol/device-type
root@63f8d1977f88:~/ncs-instance# 
root@63f8d1977f88:~# ncs --version
5.5
```
You may also try to login via `ncs_cli` command
```bash
root@63f8d1977f88:~/ncs-instance# ncs_cli -C -u admin

User admin last logged in 2022-05-23T19:29:37.671064+00:00, to 63f8d1977f88, from 172.17.0.1 using webui-http
admin connected from 127.0.0.1 using console on 63f8d1977f88
admin@ncs# 
admin@ncs# exit
root@63f8d1977f88:~/ncs-instance#
```
Try login via `ssh` and `webui`, default username/password is admin/admin.
```bash
(main) expert@expert-cws:~/nso$ ssh -p2024 admin@localhost
The authenticity of host '[localhost]:2024 ([127.0.0.1]:2024)' can't be established.
ED25519 key fingerprint is SHA256:SGZ0MdK6yHp8IMg8hOkd1aQyX053+Y4PE7XPeXRjFXo.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '[localhost]:2024' (ED25519) to the list of known hosts.
admin@localhost's password: 

User admin last logged in 2022-05-23T19:30:06.270458+00:00, to 63f8d1977f88, from 127.0.0.1 using cli-console
admin connected from 172.17.0.1 using ssh on 63f8d1977f88
admin@ncs> 
```
![App Screenshot](https://github.com/muhammad-rafi/cisco-nso-docker/blob/main/images/nso-webui_1.png)

![App Screenshot](https://github.com/muhammad-rafi/cisco-nso-docker/blob/main/images/nso-webui_2.png)

## Author

[Muhammad Rafi](https://www.linkedin.com/in/muhammad-rafi-0a37a248/)
