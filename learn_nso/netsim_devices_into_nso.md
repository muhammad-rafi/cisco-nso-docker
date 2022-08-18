# How to add, delete and load netsim devices into NSO Instance

### Go to your NSO instance 

```bash
root@nso:~# cd ncs-instance/
root@nso:~/ncs-instance# 
```

You can create a single IOS netsim device `R0` using the following command. 

### Create a Cisco IOS device 'R0' using 'cisco-ios-cli-6.69' ned

`ncs-netsim create-device packages/cisco-ios-cli-6.69 R0`

```bash
root@nso:~/ncs-instance# ncs-netsim create-device packages/cisco-ios-cli-6.69 R0
DEVICE R0 CREATED
```

OR 

### Create a Network of IOS devices 'R0 and R1' using 'cisco-ios-cli-6.69' ned

`ncs-netsim create-network packages/cisco-ios-cli-6.69 R`

```bash
root@nso:~/ncs-instance# ncs-netsim create-network packages/cisco-ios-cli-6.69 2 R
DEVICE R0 CREATED
DEVICE R1 CREATED
root@nso:~/ncs-instance# 
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

Note: Don't use `R` keyword again to add more devices if you already used R0 or R1 to add the single device or multiple devices before, otherwise you may get the unexpected results. just name them something other than `R`. 

Here is what you would need to avoid adding more devices with `R` name if you already have R0 created before
`ncs-netsim add-to-network packages/cisco-ios-cli-6.69 2 R`

Now, let's add more devices using 'cisco-ios-cli-6.69' ned in the current network, I am adding 2 more device 'CE0 and CE1'

### Add more devices 'CE0 and CE1' in the existing network using 'cisco-ios-cli-6.69' ned

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

```bash
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
```

You can also delete the network by follwoing command 

### Deleting the `netsim` network 

`ncs-netsim delete-network`

```bash
root@nso:~/ncs-instance# ncs-netsim delete-network
DEVICE R0 already STOPPED
DEVICE CE0 already STOPPED
DEVICE CE1 already STOPPED
root@nso:~/ncs-instance# 
```

Once you deleted the network, you will notice, 'netsim' folder would go away too. 

```bash
root@nso:~/ncs-instance# ls -l
total 44
-rw-r--r-- 1 root root   714 May 31 12:13 README.ncs
drwxr-xr-x 2 root root  4096 Aug 18 10:37 logs
drwxr-xr-x 2 root root  4096 Aug 18 10:37 ncs-cdb
-rw-r--r-- 1 root root 10021 May 31 12:13 ncs.conf
drwxr-xr-x 7 root root  4096 Aug  2 18:51 packages
drwxr-xr-x 4 root root  4096 May 31 12:13 scripts
drwxr-xr-x 5 root root  4096 Aug 18 10:38 state
-rw-r--r-- 1 root root   289 Aug 18 10:38 storedstate
drwxr-xr-x 3 root root  4096 May 31 12:14 target
root@nso:~/ncs-instance# 
```

Next step is to load the devices on NSO.

# Load Netsim devices into NSO

### Go to your NSO instance 

```bash
root@nso:~# cd ncs-instance/
root@nso:~/ncs-instance# 
```

### Create a Network of IOS devices 'R0 and R1' using 'cisco-ios-cli-6.69' ned

Since we deleted the devices earlier in above step, let's quickly create two ios `netsim` devices `R0` and `R1` and start the netsim devices.

```bash
root@nso:~/ncs-instance# ncs-netsim create-network packages/cisco-ios-cli-6.69 2 R
DEVICE R0 CREATED
DEVICE R1 CREATED
root@nso:~/ncs-instance# 
```

```bash
root@nso:~/ncs-instance# ncs-netsim start
DEVICE R0 OK STARTED
DEVICE R1 OK STARTED
root@nso:~/ncs-instance# 
```

### Export netsim devices connection data to NSO

```bash
root@nso:~/ncs-instance# ncs-netsim ncs-xml-init > netsim_devices.xml
root@nso:~/ncs-instance# 
```
If you see a below error when exporting, make sure you have `xsltproc` installed.

`/nso-5.5/bin/ncs-netsim: line 897: xsltproc : command not found`

Install `xsltproc` in case of above error and run the export again.

`root@nso:~/ncs-instance# apt-get install -y xsltproc`

Next step to get the devices add on NSO via CLI. 

### Login to the nso CLI, load merge the netsim devices and commit the change

`ncs_cli -u admin -C`
`load merge netsim_devices.xml`

```bash
root@nso:~/ncs-instance# ncs_cli -u admin -C

User admin last logged in 2022-08-18T13:07:29.919317+00:00, to nso, from 127.0.0.1 using cli-console
admin connected from 127.0.0.1 using console on nso
admin@ncs# config t
Entering configuration mode terminal
admin@ncs(config)# load merge netsim_devices.xml
Loading.
2.16 KiB parsed in 0.01 sec (165.08 KiB/sec)
admin@ncs(config)# 
admin@ncs(config)# commit   
Commit complete.
admin@ncs(config)# end     
admin@ncs# 
```

### Check the full configuration for these device e.g. R0

```bash
admin@ncs(config)# show full-configuration devices device R0 
devices device R0
 address   127.0.0.1
 port      10022
 ssh host-key ssh-rsa
  key-data "AAAAB3NzaC1yc2EAAAADAQABAAABgQDAfCkCcFwwdlfNv82l4H75i2/4f+1C61aR4KtiNihs\nGEPhS7U+56TQUnYL9Ho3NZSJ+pD2e+9h6vgXdK71zlFc8eSIdaZWgmdKd6Y7PrYXu//+VDBc\n7Jq4olYAz7PaC1Dl35/ZkEswXhuPY7f7tf5MV3578bZ4dNGYIMcm79Q4AM67z/4OO+YWilbX\nIJBUjywlUDgun2dTAlQE27XBbyPSfXjhIPyzI/3m5MK2U1yCkZT1MifQTvE/f5AJhFuekniJ\nme+H/ONLbvLfTb5r6YGrTHzh33Raup8pJ9qatUtspvMf2tqRvPt+CFpNne2CInvXGld8GV2r\nOetj29cehPINW9S+N1G2N4xlc7woOuTGN2JjTMYLbFgG/gmvUDY6dfvvuV7kuCrFiKCw2Zj+\ncRrztaXI1Y1ILHbh9Fy8DvJKeokXBw4otd2YiZqDg85zxDgkpGeCQa+efm/WBB0WoN7o+lZL\nBEExN69HmaIRrSfgAv/ZoKNdb/0WocrHJ/7Rb0M="
 !
 authgroup default
 device-type cli ned-id cisco-ios-cli-6.69
 state admin-state unlocked
 config
  no service password-encryption
  no cable admission-control preempt priority-voice
  no cable qos permission create
  no cable qos permission update
  no cable qos permission modems
  ip source-route
  no ip cef
  no ip forward-protocol nd
  no ipv6 cef
  no dot11 syslog
 !
!
admin@ncs(config)# 
```

### Check the state of the devices

```bash
admin@ncs# show devices device state 
devices device R0
 state oper-state unknown
devices device R1
 state oper-state unknown
```

### Check the sync status of the devices

```bash
admin@ncs(config)# devices check-sync
sync-result {
    device R0
    result unknown
}
sync-result {
    device R1
    result unknown
}
```

As you can see both state and check-sync are unknown, so we need to first run the sync from the device for NSO to import devices current configuration into NSO. 

### Run sync-from 

```bash
admin@ncs# devices sync-from 
sync-result {
    device R0
    result true
}
sync-result {
    device R1
    result true
}
```

Now the `netsim` devices are in sync state, let's check the state again. 

```bash
admin@ncs# show devices device state
devices device R0
 state oper-state    enabled
 state transaction-mode ned
 state last-transaction-id 8b4d5a2317f421fa0498afac619e0d0c
devices device R1
 state oper-state    enabled
 state transaction-mode ned
 state last-transaction-id 8b4d5a2317f421fa0498afac619e0d0c
admin@ncs# 

 ```

Looks good, right, so we now have 'netsim' devices up and running and we can test our service packages and configuration. 

I found another good article to create netsim devices from the real devices config, please check out the link below;

##### How to create a NETSIM from real device configuration
_https://community.cisco.com/t5/nso-developer-hub-blogs/how-to-create-a-netsim-from-real-device-configuration/ba-p/3663976_

Here you Go ! 

You learnt, how to add, delete and load 'netsim' virtual devices in NSO instance. 

Next, we will explore how to work with `netsim` devices.

_Reference: https://www.ciscolive.com/c/dam/r/ciscolive/emea/docs/2018/pdf/LABSPG-2442-LG.pdf_
