# How to Add/Install Cisco NED (Network Eelement Drive) on Cisco NSO 

I am using the Cisco NSO docker container in this example which uses local install, if you have a system install, the directories may be on different locations, please check the official NSO docs. 

CWS (Candidate Work Station) - Based on Ubuntu 20.04.3 LTS

We will be adding new cisco IOSXR NED `cisco-iosxr-cli-7.33` in this example. 

### Step 1: Download the IOSXR NED Binary

Download the NED you need from the following link
https://developer.cisco.com/docs/nso/#!getting-and-installing-nso/download-your-nso-free-trial-installer-and-cisco-neds

I downloaded the IOSXR NED `ncs-5.5-cisco-iosxr-7.33.signed.bin` in this example. However you might see the different or latest NED for the latest NSO version.

### Step 2: Extract the IOSXR NED Binary

Run `sh ncs-5.5-cisco-iosxr-7.33.signed.bin`

```bash
murafi@MURAFI-M-VC10:packages$ sh ncs-5.5-cisco-iosxr-7.33.signed.bin 
Unpacking...
Verifying signature...
Retrieving CA certificate from http://www.cisco.com/security/pki/certs/crcam2.cer ...
Successfully retrieved and verified crcam2.cer.
Retrieving SubCA certificate from http://www.cisco.com/security/pki/certs/innerspace.cer ...
Successfully retrieved and verified innerspace.cer.
Successfully verified root, subca and end-entity certificate chain.
Successfully fetched a public key from tailf.cer.
Successfully verified the signature of ncs-5.5-cisco-iosxr-7.33.tar.gz using tailf.cer
murafi@MURAFI-M-VC10:packages$ ls -l
total 167464
-rw-r--r--  1 murafi  staff      4003  4 Feb  2021 README.signature
-rw-r--r--  1 murafi  staff     15598  4 Feb  2021 cisco_x509_verify_release.py
-rw-r--r--  1 murafi  staff     15447  4 Feb  2021 cisco_x509_verify_release.py3
-rw-r--r--@ 1 murafi  staff  42805098 13 Sep 12:45 ncs-5.5-cisco-iosxr-7.33.signed.bin
-rw-r--r--  1 murafi  staff  42816786  4 Feb  2021 ncs-5.5-cisco-iosxr-7.33.tar.gz
-rw-r--r--  1 murafi  staff       256  4 Feb  2021 ncs-5.5-cisco-iosxr-7.33.tar.gz.signature
-rw-r--r--  1 murafi  staff      1383  4 Feb  2021 tailf.cer
murafi@MURAFI-M-VC10:packages$
```

### Step 3: Copy `ncs-5.5-cisco-iosxr-7.33.tar.gz` to your CWS from your local machine (macbook in my case)

Delete all the other files except `ncs-5.5-cisco-iosxr-7.33.tar.gz` and copy it over to your CWS or Ubuntu box where your NSO instance or docker is running.

```bash
murafi@MURAFI-M-VC10:packages$ scp ncs-5.5-cisco-iosxr-7.33.tar.gz expert@localhost:~/nso/packages/
expert@localhost's password: 
ncs-5.5-cisco-iosxr-7.33.tar.gz                                                                    100%   41MB  54.5MB/s   00:00    
murafi@MURAFI-M-VC10:packages$ 
```

### Step 4: Go to your CWS or Ubuntu Box and extract `ncs-5.5-cisco-iosxr-7.33.tar.gz`

Run `tar -zxvf ncs-5.5-cisco-iosxr-7.33.tar.gz`

```bash
(main) expert@expert-cws:~/nso/packages$ tar -zxvf ncs-5.5-cisco-iosxr-7.33.tar.gz
cisco-iosxr-cli-7.33/
cisco-iosxr-cli-7.33/doc/
cisco-iosxr-cli-7.33/CHANGES
cisco-iosxr-cli-7.33/load-dir/
cisco-iosxr-cli-7.33/load-dir/ietf-interfaces.fxs
cisco-iosxr-cli-7.33/load-dir/tailf-ned-loginscripts.fxs
cisco-iosxr-cli-7.33/load-dir/tailf-ned-cisco-ios-xr-oper.fxs
cisco-iosxr-cli-7.33/load-dir/tailf-ned-cisco-ios-xr-meta.fxs
cisco-iosxr-cli-7.33/load-dir/tailf-ned-cisco-ios-xr.fxs
! output ommitted !
```
When you run this command you will see bunch of output but watch out for any errors, if no error, you will see the following directory is created in your current directory 

`cisco-iosxr-cli-7.33`

```bash
(main) expert@expert-cws:~/nso/packages$ ls -l
total 107376
drwxr-xr-x 9 expert expert     4096 Feb  4  2021 cisco-iosxr-cli-7.33
-rw-r--r-- 1 expert expert 57809612 Feb  5  2021 ncs-5.5-cisco-ios-6.69.tar.gz
-rw-r--r-- 1 expert expert 42816786 Sep 13 12:08 ncs-5.5-cisco-iosxr-7.33.tar.gz
-rw-r--r-- 1 expert expert  9316936 Jan 13  2021 ncs-5.5-cisco-nx-5.21.tar.gz
(main) expert@expert-cws:~/nso/packages$ 
```

### Step 5: Copy the directory `cisco-iosxr-cli-7.33` to Cisco NSO docker or Instance

Let's start the container and start the ncs instance, if it is currently in Exited state. 

```bash
(main) expert@expert-cws:~/nso/packages$ docker ps -a
CONTAINER ID   IMAGE                                 COMMAND                  CREATED        STATUS                      PORTS                                                                                                                                  NAMES
103ad040aeef   gcr.io/k8s-minikube/kicbase:v0.0.27   "/usr/local/bin/entr…"   3 weeks ago    Exited (255) 2 weeks ago    127.0.0.1:49187->22/tcp, 127.0.0.1:49186->2376/tcp, 127.0.0.1:49185->5000/tcp, 127.0.0.1:49184->8443/tcp, 127.0.0.1:49183->32443/tcp   minikube
026afd517aee   jeremycohoe/tig_mdt                   "/start.sh"              2 months ago   Exited (137) 2 months ago                                                                                                                                          clever_kowalevski
a9472af3bcaf   cisco-nso-dev:0.1                     "bash"                   3 months ago   Exited (0) 3 weeks ago                                                                                                                                             cisco-nso-dev

(main) expert@expert-cws:~/nso/packages$ docker start cisco-nso-dev
cisco-nso-dev
(main) expert@expert-cws:~/nso/packages$ 
(main) expert@expert-cws:~/nso/packages$ docker exec -it cisco-nso-dev bash
root@nso:~#
root@nso:~/ncs-instance# ncs
root@nso:~/ncs-instance# 
root@nso:~/ncs-instance# ncs --status | grep status
status: started
        db=running id=33 priority=1 path=/ncs:devices/device/live-status-protocol/device-type
root@nso:~/ncs-instance# 
```

check what NEDs we currently have 

```bash
root@nso:~# ls -l nso-5.5/packages/neds/
total 48
drwxr-xr-x 8 root root  4096 Dec 21  2020 a10-acos-cli-3.0
drwxr-xr-x 7 root root  4096 Dec 21  2020 alu-sr-cli-3.4
drwxr-xr-x 8 root root  4096 Dec 21  2020 cisco-asa-cli-6.6
drwxr-xr-x 7 root root  4096 Dec 21  2020 cisco-ios-cli-3.0
drwxr-xr-x 7 root root  4096 Dec 21  2020 cisco-ios-cli-3.8
drwxr-xr-x 8 9001 users 4096 Feb  4  2021 cisco-ios-cli-6.69
drwxr-xr-x 8 root root  4096 Dec 21  2020 cisco-iosxr-cli-3.0
drwxr-xr-x 8 root root  4096 Dec 21  2020 cisco-iosxr-cli-3.5
drwxr-xr-x 8 root root  4096 Dec 21  2020 cisco-nx-cli-3.0
drwxr-xr-x 9 9001 users 4096 Jan 12  2021 cisco-nx-cli-5.21
drwxr-xr-x 8 root root  4096 Dec 21  2020 dell-ftos-cli-3.0
drwxr-xr-x 5 root root  4096 Dec 21  2020 juniper-junos-nc-3.0
root@nso:~# 
```

You can see we do not have `cisco-iosxr-cli-7.33`, let's exit out of the NSO container and back to host and copy the new NED to this nso docker container.

`$ docker cp cisco-iosxr-cli-7.33 cisco-nso-dev:/root/nso-5.5/packages/neds/`

```bash
root@nso:~# exit
exit
(main) expert@expert-cws:~/nso/packages$ docker cp cisco-iosxr-cli-7.33 cisco-nso-dev:/root/nso-5.5/packages/neds/
```

It seems like it has been copied over to the nso docker, let's verfiy it by going to the docker container 

```bash
(main) expert@expert-cws:~/nso/packages$ docker exec -it cisco-nso-dev bash
root@nso:~# ls -l nso-5.5/packages/neds/
total 52
drwxr-xr-x 8 root root  4096 Dec 21  2020 a10-acos-cli-3.0
drwxr-xr-x 7 root root  4096 Dec 21  2020 alu-sr-cli-3.4
drwxr-xr-x 8 root root  4096 Dec 21  2020 cisco-asa-cli-6.6
drwxr-xr-x 7 root root  4096 Dec 21  2020 cisco-ios-cli-3.0
drwxr-xr-x 7 root root  4096 Dec 21  2020 cisco-ios-cli-3.8
drwxr-xr-x 8 9001 users 4096 Feb  4  2021 cisco-ios-cli-6.69
drwxr-xr-x 8 root root  4096 Dec 21  2020 cisco-iosxr-cli-3.0
drwxr-xr-x 8 root root  4096 Dec 21  2020 cisco-iosxr-cli-3.5
drwxr-xr-x 9 1001  1002 4096 Feb  4  2021 cisco-iosxr-cli-7.33
drwxr-xr-x 8 root root  4096 Dec 21  2020 cisco-nx-cli-3.0
drwxr-xr-x 9 9001 users 4096 Jan 12  2021 cisco-nx-cli-5.21
drwxr-xr-x 8 root root  4096 Dec 21  2020 dell-ftos-cli-3.0
drwxr-xr-x 5 root root  4096 Dec 21  2020 juniper-junos-nc-3.0
root@nso:~# 
```
We can see that `cisco-iosxr-cli-7.33` has been copied over to the NSO docker container. 

### Step 6: Create a Symbolic (soft) link for `cisco-iosxr-cli-7.33` for the ncs instance 

As we are using ncs-instance in NSO, so NSO looks for directory under the `/root/ncs-instance/packages` for packages, therefore we need to create a symbolic link points to this directory.

`ln -s /root/nso-5.5/packages/neds/cisco-iosxr-cli-7.33 /root/ncs-instance/packages/`

`ln` - link command in Linux 
`-s` - Symbolic Link or Soft Link  
`/root/nso-5.5/packages/neds/cisco-iosxr-cli-7.33` - Symbolic Link from 
`/root/ncs-instance/packages/` - Symbolic Link to

```bash
root@nso:~/nso-5.5/packages/neds# pwd   
/root/nso-5.5/packages/neds
root@nso:~/nso-5.5/packages/neds# ln -s /root/nso-5.5/packages/neds/cisco-iosxr-cli-7.33 /root/ncs-instance/packages/
root@nso:~/nso-5.5/packages/neds# cd
root@nso:~# cd ncs-instance/packages/
root@nso:~/ncs-instance/packages# ls -l
total 16
lrwxrwxrwx 1 root root   46 May 31 12:13 cisco-ios-cli-6.69 -> /root/nso-5.5/packages/neds/cisco-ios-cli-6.69
lrwxrwxrwx 1 root root   48 Sep 13 17:39 cisco-iosxr-cli-7.33 -> /root/nso-5.5/packages/neds/cisco-iosxr-cli-7.33
lrwxrwxrwx 1 root root   45 May 31 12:13 cisco-nx-cli-5.21 -> /root/nso-5.5/packages/neds/cisco-nx-cli-5.21
drwxr-xr-x 6 root root 4096 Jun  6 17:53 ipython-superuser
drwxr-xr-x 6 root root 4096 Jun  4 11:46 loopback-service
drwxr-xr-x 8 root root 4096 Jun  7 00:22 nso-loopback-service
root@nso:~/ncs-instance/packages# 
```

As you can see Symbolic link is created for the new NED, finally login to the NSO cli and reload the package. 

### Step 7: Reload Packages in NSO CLI 

Login to the NSO cli and run `packages reload`

```bash
root@nso:~/ncs-instance/packages# ncs_cli -u admin -C

User admin last logged in 2022-09-13T17:22:43.435765+00:00, to nso, from 127.0.0.1 using cli-console
admin connected from 127.0.0.1 using console on nso
admin@ncs# packages reload

>>> System upgrade is starting.
>>> Sessions in configure mode must exit to operational mode.
>>> No configuration changes can be performed until upgrade has completed.
>>> System upgrade has completed successfully.
reload-result {
    package cisco-ios-cli-6.69
    result true
}
reload-result {
    package cisco-iosxr-cli-7.33
    result true
}
reload-result {
    package cisco-nx-cli-5.21
    result true
}
reload-result {
    package ipython-superuser
    result true
}
reload-result {
    package loopback-service
    result true
}
reload-result {
    package nso-loopback-service
    result true
}
admin@ncs# 
System message at 2022-09-13 18:08:10...
    Subsystem stopped: ncs-dp-4-cisco-nx-cli-5.21:NexusDp
admin@ncs# 
System message at 2022-09-13 18:08:10...
    Subsystem stopped: ncs-dp-3-cisco-ios-cli-6.69:IOSDp
admin@ncs# 
System message at 2022-09-13 18:08:10...
    Subsystem started: ncs-dp-5-cisco-ios-cli-6.69:IOSDp
admin@ncs# 
System message at 2022-09-13 18:08:10...
    Subsystem started: ncs-dp-6-cisco-nx-cli-5.21:NexusDp
admin@ncs# 
```

From you the above output, you can see the following, which means new IOSXR NED `cisco-iosxr-cli-7.33` has been added to the NSO instance ready for use. 

```s
reload-result {
    package cisco-iosxr-cli-7.33
    result true
}
```