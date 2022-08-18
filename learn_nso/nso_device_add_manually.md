## How to add and delete netsim devices in NSO Instance

##### Go to your NSO instance 
```bash
root@nso:~# cd ncs-instance/
root@nso:~/ncs-instance# 
```

You can create a single IOS netsim device `R0` using the following command. 

##### Create a Cisco IOS device 'R0' using 'cisco-ios-cli-6.69' ned

`ncs-netsim create-device packages/cisco-ios-cli-6.69 R0`

```bash
root@nso:~/ncs-instance# ncs-netsim create-device packages/cisco-ios-cli-6.69 R0
DEVICE R0 CREATED
```

__Note: make sure you replace `packages/cisco-ios-cli-6.69` with the ned package you have it in your NSO instance.__

You also notice that, once you create a device, it will also create a `netsim` directory in your current folder.

```bash
root@nso:~/ncs-instance# ls -l
total 48
-rw-r--r-- 1 root root   714 May 31 12:13 README.ncs
drwxr-xr-x 2 root root  4096 Aug 18 10:37 logs
drwxr-xr-x 2 root root  4096 Aug 18 10:37 ncs-cdb
-rw-r--r-- 1 root root 10021 May 31 12:13 ncs.conf
drwxr-xr-x 3 root root  4096 Aug 18 11:41 netsim
drwxr-xr-x 7 root root  4096 Aug  2 18:51 packages
drwxr-xr-x 4 root root  4096 May 31 12:13 scripts
drwxr-xr-x 5 root root  4096 Aug 18 10:38 state
-rw-r--r-- 1 root root   289 Aug 18 10:38 storedstate
drwxr-xr-x 3 root root  4096 May 31 12:14 target
root@nso:~/ncs-instance# ls -l netsim/
total 8
drwxr-xr-x 3 root root 4096 Aug 18 11:41 R0
-rw-r--r-- 1 root root  653 Aug 18 11:41 README.netsim
root@nso:~/ncs-instance# 
```

If you like to add more devices in the existing `netsim` network, you can run the follwoing command, you may add devices with different neds, however in this example, I use same `ios` ned, I used for adding a single ios device above.

Note: Don't use `R` keyword again to add more devices if you already used R0 to add the single device before, otherwise you may get the unexpected results. just name them something other than `R`. 

Here is what you would need to avoid adding more devices with `R` name if you already have R0 created before
`ncs-netsim add-to-network packages/cisco-ios-cli-6.69 2 R`

Now, let's add more devices using 'cisco-ios-cli-6.69' ned in the current network, I am adding 2 more device 'CE0 and CE1'

##### Add more devices 'CE0 and CE1' in the existing network using 'cisco-ios-cli-6.69' ned

`ncs-netsim add-to-network packages/cisco-ios-cli-6.69 2 CE`

```bash
root@nso:~/ncs-instance# ncs-netsim add-to-network packages/cisco-ios-cli-6.69 2 CE
DEVICE CE0 CREATED
DEVICE CE1 CREATED
```

Check the `netsim` directory again

```bash
root@nso:~/ncs-instance# ls -l netsim/
total 12
drwxr-xr-x 4 root root 4096 Aug 18 11:47 CE
drwxr-xr-x 3 root root 4096 Aug 18 11:47 R0
-rw-r--r-- 1 root root  913 Aug 18 11:47 README.netsim
root@nso:~/ncs-instance# ls -l netsim/CE/
total 8
drwxr-xr-x 5 root root 4096 Aug 18 11:47 CE0
drwxr-xr-x 5 root root 4096 Aug 18 11:47 CE1
root@nso:~/ncs-instance# 
```

You can see now, new folder added in `netsim` directory called `CE` and in that `CE` folder you have two more devices `CE0 and CE1`

If you like to explore what is inside those device name directory, check it out, there are multiple scripts sitting there for the device simulation. 

Lets's explore 'R0'

root@nso:~/ncs-instance# ls -l netsim/R0/R0/
total 9972
-rw-r--r-- 1 root root     5230 Aug 18 11:47 aaa.fxs
drwxr-xr-x 2 root root     4096 Aug 18 11:47 cdb
-rwxr-xr-x 1 root root      183 Aug 18 11:47 cli.sh
-rw-r--r-- 1 root root    10084 Aug 18 11:47 client_pnp.beam
-rw-r--r-- 1 root root      800 Aug 18 11:47 confd.c.ccl
-rw-r--r-- 1 root root     8177 Aug 18 11:47 confd.conf
-rw-r--r-- 1 root root     8221 Aug 18 11:47 confd.conf.netsim
-rw-r--r-- 1 root root      875 Aug 18 11:47 confd.i.ccl
-rw-r--r-- 1 root root      493 Aug 18 11:47 env.sh
-rw-r--r-- 1 root root     4178 Aug 18 11:47 ietf-netconf-acm.fxs
drwxr-xr-x 2 root root     4096 Aug 18 11:47 logs
-rwxr-xr-x 1 root root      602 Aug 18 11:47 ping.sh
-rw-r--r-- 1 root root     9200 Aug 18 11:47 purl.beam
-rwxr-xr-x 1 root root       27 Aug 18 11:47 show_arp.sh
-rwxr-xr-x 1 root root       27 Aug 18 11:47 show_bgp.sh
-rwxr-xr-x 1 root root       27 Aug 18 11:47 show_crypto.sh
-rwxr-xr-x 1 root root       27 Aug 18 11:47 show_interfaces.sh
-rwxr-xr-x 1 root root       27 Aug 18 11:47 show_lldp.sh
-rwxr-xr-x 1 root root       54 Aug 18 11:47 show_version.sh
-rwxr-xr-x 1 root root       27 Aug 18 11:47 show_vrf.sh
drwxr-xr-x 2 root root     4096 May 23 18:54 ssh
-rwxr-xr-x 1 root root      116 Aug 18 11:47 start.sh
-rwxr-xr-x 1 root root       40 Aug 18 11:47 status.sh
-rwxr-xr-x 1 root root       50 Aug 18 11:47 stop.sh
-rw-r--r-- 1 root root 10064822 Aug 18 11:47 tailf-ned-cisco-ios.fxs
-rw-r--r-- 1 root root     5336 Aug 18 11:47 xml_parser.beam
root@nso:~/ncs-instance# 


You can also delete the network by follwoing command 

#### Deleting the `netsim` network 

`ncs-netsim delete-network`

```bash
root@nso:~/ncs-instance# ncs-netsim delete-network
DEVICE R0 already STOPPED
DEVICE CE0 already STOPPED
DEVICE CE1 already STOPPED
root@nso:~/ncs-instance# 
```

Here you Go ! 

You learnt, how to added and delete 'netsim' virtual devices in NSO instance. 

Next, we will explore how to work with `netsim` devices.
