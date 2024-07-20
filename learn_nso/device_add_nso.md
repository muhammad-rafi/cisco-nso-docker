
##### Login to NSO and Reload Packages 
root@cisco-nso-dev:~# ncs_cli -u admin -C
```sh
User admin last logged in 2024-06-17T23:55:04.502788+00:00, to cisco-nso-dev, from 10.209.217.3 using webui-http
admin connected from 127.0.0.1 using console on cisco-nso-dev
admin@ncs# 
admin@ncs# 
admin@ncs# packages reload
reload-result {
    package cisco-asa-cli-6.18
    result true
}
reload-result {
    package cisco-ios-cli-6.106
    result true
}
reload-result {
    package cisco-iosxr-cli-7.55
    result true
}
reload-result {
    package cisco-nx-cli-5.25
    result true
}
admin@ncs# 
System message at 2024-06-18 09:05:21...
    Subsystem stopped: ncs-dp-1-cisco-asa-cli-6.18:ASADp
admin@ncs# 
System message at 2024-06-18 09:05:21...
    Subsystem stopped: ncs-dp-2-cisco-ios-cli-6.106:IOSDp
admin@ncs# 
System message at 2024-06-18 09:05:21...
    Subsystem stopped: ncs-dp-3-cisco-nx-cli-5.25:NexusDp
admin@ncs# 
System message at 2024-06-18 09:05:21...
    Subsystem started: ncs-dp-4-cisco-asa-cli-6.18:ASADp
admin@ncs# 
System message at 2024-06-18 09:05:21...
    Subsystem started: ncs-dp-5-cisco-ios-cli-6.106:IOSDp
admin@ncs# 
```

##### Setting up devices authentication group

To add your physical/virtual device on NSO, you need first create a authgroup which enables NSO to read/write data to and from your device. Authgroup contains your devices login credentials to make changes or read the data from the devices.

As you can see there is no devices exist in the NSO
```sh
admin@ncs# show devices list
NAME  ADDRESS  DESCRIPTION  NED ID  ADMIN STATE  
-----------------------------------------------
admin@ncs# 
admin@ncs# 
admin@ncs# 
```

```sh
admin@ncs# config 
Entering configuration mode terminal
admin@ncs(config)# devices authgroups ?
Possible completions:
  group        Authentication settings for a group of devices
  snmp-group   SNMP authentication groups
admin@ncs(config)# devices authgroups group ?
This line doesn't have a valid range expression
Possible completions:
  The name of the authgroup  default
admin@ncs(config)# devices authgroups group cmladmin
admin@ncs(config-group-cmladmin)#
admin@ncs(config-group-cmladmin)# default-map remote-name ?
Description: Specify device user name
Possible completions:
  <string>
admin@ncs(config-group-cmladmin)# default-map remote-name admin ?
Possible completions:
  public-key                  Use public-key authentication
  remote-password             Specify the remote password
  remote-secondary-password   Second password for configuration
  same-pass                   Use the local NCS password as the remote password
  same-secondary-password     Use the local NCS password as the remote secondary password
  <cr>                        
admin@ncs(config-group-cmladmin)# default-map remote-name admin remote-?
Possible completions:
  remote-password             Specify the remote password
  remote-secondary-password   Second password for configuration
admin@ncs(config-group-cmladmin)# default-map remote-name admin remote-password ?
Description: Specify the remote password
Possible completions:
  <AES256 encrypted string>
admin@ncs(config-group-cmladmin)# default-map remote-name admin remote-password C1sco123 ?
Possible completions:
  remote-secondary-password   Second password for configuration
  same-secondary-password     Use the local NCS password as the remote secondary password
  <cr>                        
admin@ncs(config-group-cmladmin)# default-map remote-name admin remote-password C1sco123 remote-secondary-password C1sco123 ?
Possible completions:
  <cr>
admin@ncs(config-group-cmladmin)# default-map remote-name admin remote-password C1sco123 remote-secondary-password C1sco123 
admin@ncs(config-group-cmladmin)# commit dry-run outformat cli 
cli {
    local-node {
        data  devices {
                  authgroups {
             +        group cmladmin {
             +            default-map {
             +                remote-name admin;
             +                remote-password $9$2aV3KonG/iOp18KzwtSvLeQuj+nsDmmnZhMGdlRTJTs=;
             +                remote-secondary-password $9$wNOCrOZKJuGvE/1SyQczrFDmHyskhFYRuABO5OtZlH0=;
             +            }
             +        }
                  }
              }
    }
}
admin@ncs(config-group-cmladmin)# commit dry-run outformat cli-c 
cli-c {
    local-node {
        data devices authgroups group cmladmin
              default-map remote-name admin
              default-map remote-password $9$2aV3KonG/iOp18KzwtSvLeQuj+nsDmmnZhMGdlRTJTs=
              default-map remote-secondary-password $9$wNOCrOZKJuGvE/1SyQczrFDmHyskhFYRuABO5OtZlH0=
             !
    }
}
admin@ncs(config-group-cmladmin)#
admin@ncs(config-group-cmladmin)# commit label authgroup-cmladmin-added 
Commit complete.
admin@ncs(config-group-cmladmin)# end
admin@ncs# show configuration commit list 
2024-06-18 09:32:41
SNo.  ID       User       Client      Time Stamp          Label       Comment
~~~~  ~~       ~~~~       ~~~~~~      ~~~~~~~~~~          ~~~~~       ~~~~~~~
10002 10002    admin      cli         2024-06-18 09:32:12 authgroup-c 
10001 10001    system     system      2024-06-17 11:56:35             
admin@ncs# 
```

In short, we added the following configuration
```s
config
devices authgroups group cmladmin
default-map remote-name admin
default-map remote-password C1sco123
default-map remote-secondary-password C1sco123
!
```

##### Add devices to Cisco NSO

The device's IP address or FQDN.
The protocol (SSH, Telnet, HTTP, REST, and so on) and port (if nonstandard) to connect to the device.
The authgroup to use for the device (which must be committed before adding devices).
The NED (device driver) to use to connect to the device.

```sh
admin@ncs# config 
Entering configuration mode terminal
admin@ncs(config)# devices device cml-core-rtr01
admin@ncs(config-device-cml-core-rtr01)# address 10.251.13.203
admin@ncs(config-device-cml-core-rtr01)# authgroup cmladmin
admin@ncs(config-device-cml-core-rtr01)# device-type cli ?
Possible completions:
  ned-id     The NED Identity
  protocol   The CLI protocol
admin@ncs(config-device-cml-core-rtr01)# device-type cli ned-id ?
Description: The NED Identity
Possible completions:
  cisco-asa-cli-6.18     
  cisco-ios-cli-6.106    
  cisco-iosxr-cli-7.55   
  cisco-nx-cli-5.25      
  lsa-netconf            Base identity for LSA nodes.
  netconf                Default identity for a netconf device.
  snmp                   Default identity for an SNMP device.
admin@ncs(config-device-cml-core-rtr01)# device-type cli ned-id cisco-iosxr-cli-7.55 ?
Possible completions:
  protocol   The CLI protocol
  <cr>       
admin@ncs(config-device-cml-core-rtr01)# device-type cli ned-id cisco-iosxr-cli-7.55 protocol ?
Description: The CLI protocol
Possible completions:
  ssh  telnet
admin@ncs(config-device-cml-core-rtr01)# device-type cli ned-id cisco-iosxr-cli-7.55 protocol ssh ?
Possible completions:
  <cr>
admin@ncs(config-device-cml-core-rtr01)# device-type cli ned-id cisco-iosxr-cli-7.55 protocol ssh 
admin@ncs(config-device-cml-core-rtr01)# ssh host-key-verification none
admin@ncs(config-device-cml-core-rtr01)# commit dry-run outformat xml   
result-xml {
    local-node {
        data <devices xmlns="http://tail-f.com/ns/ncs">
               <device>
                 <name>cml-core-rtr01</name>
                 <address>10.251.13.203</address>
                 <ssh>
                   <host-key-verification>none</host-key-verification>
                 </ssh>
                 <authgroup>cmladmin</authgroup>
                 <device-type>
                   <cli>
                     <ned-id xmlns:cisco-iosxr-cli-7.55="http://tail-f.com/ns/ned-id/cisco-iosxr-cli-7.55">cisco-iosxr-cli-7.55:cisco-iosxr-cli-7.55</ned-id>
                     <protocol>ssh</protocol>
                   </cli>
                 </device-type>
               </device>
             </devices>
    }
}
admin@ncs(config-device-cml-core-rtr01)# commit dry-run outformat cli-c 
cli-c {
    local-node {
        data devices device cml-core-rtr01
              address 10.251.13.203
              ssh host-key-verification none
              authgroup cmladmin
              device-type cli ned-id cisco-iosxr-cli-7.55
              device-type cli protocol ssh
              config
               admin
                exit-admin-config
               !
              !
             !
    }
}
admin@ncs(config-device-cml-core-rtr01)#
admin@ncs(config-device-cml-core-rtr01)# pwd
Current submode path:
  devices device cml-core-rtr01
admin@ncs(config-device-cml-core-rtr01)# 
admin@ncs(config-device-cml-core-rtr01)# commit label added-cml-core-rtr01
Commit complete.
admin@ncs(config-device-cml-core-rtr01)# 
admin@ncs(config-device-cml-core-rtr01)# connect 
result false
info Device cml-core-rtr01 is southbound locked
admin@ncs(config-device-cml-core-rtr01)# 
admin@ncs(config-device-cml-core-rtr01)# 
admin@ncs(config-device-cml-core-rtr01)# state admin-state unlocked
admin@ncs(config-device-cml-core-rtr01)# commit
Commit complete.
admin@ncs(config-device-cml-core-rtr01)# connect
result true
info (admin) Connected to cml-core-rtr01 - 10.251.13.203:22
admin@ncs(config-device-cml-core-rtr01)# 
```

##### Add multiple devices on NSO 

Run the following command to get the list of current devices on NSO 

show running-config devices device | de-select config
```sh
admin@ncs# show running-config devices device | de-select config
devices device cml-core-rtr01
 address   10.251.13.203
 ssh host-key-verification none
 authgroup cmladmin
 device-type cli ned-id cisco-iosxr-cli-7.55
 device-type cli protocol ssh
 state admin-state unlocked
!
admin@ncs# 
```

Copy the output of the above command and save into a file, append the list of devices by following same configurations.

Go to the root folder and create a file cml_devices.txt. 

```sh 
root@cisco-nso-dev:~# pwd
/root
root@cisco-nso-dev:~#
root@cisco-nso-dev:~# cat <<EOF > cml_devices.txt
devices device cml-core-rtr01
 address   10.251.13.203
 ssh host-key-verification none
 authgroup cmladmin
 device-type cli ned-id cisco-iosxr-cli-7.55
 device-type cli protocol ssh
!
devices device cml-core-rtr02
 address   10.251.13.204
 ssh host-key-verification none
 authgroup cmladmin
 device-type cli ned-id cisco-iosxr-cli-7.55
 device-type cli protocol ssh
!
devices device cml-dist-rtr01
 address   10.251.13.205
 ssh host-key-verification none
 authgroup cmladmin
 device-type cli ned-id cisco-ios-cli-6.106
 device-type cli protocol ssh
!
devices device cml-dist-rtr02
 address   10.251.13.206
 ssh host-key-verification none
 authgroup cmladmin
 device-type cli ned-id cisco-ios-cli-6.106
 device-type cli protocol ssh
!
devices device cml-dist-sw01
 address   10.251.13.207
 ssh host-key-verification none
 authgroup cmladmin
 device-type cli ned-id cisco-nx-cli-5.25
 device-type cli protocol ssh
!
devices device cml-dist-sw02
 address   10.251.13.208
 ssh host-key-verification none
 authgroup cmladmin
 device-type cli ned-id cisco-nx-cli-5.25
 device-type cli protocol ssh
 !
!
EOF
root@cisco-nso-dev:~#
root@cisco-nso-dev:~# ls -l
total 233772
-rw-r--r--.  1 root root      1097 Jun 18 10:04 cml_devices.txt
drwxr-xr-x.  8 root root       144 Jun 17 11:58 ncs-instance
drwx------.  7 root root       160 Jun 16 10:41 neds
drwxr-xr-x. 17 root root      4096 Jun 16 10:52 nso-6.3
-rwx--x--x.  1 root root 239372542 Jun 15 21:23 nso-6.3.linux.x86_64.installer.bin
root@cisco-nso-dev:~# 
```

Merge to load the cml_devices.txt file into the NSO. 

```sh
root@cisco-nso-dev:~# ncs_cli -C -u admin

User admin last logged in 2024-06-18T09:04:19.289335+00:00, to cisco-nso-dev, from 127.0.0.1 using cli-console
admin connected from 127.0.0.1 using console on cisco-nso-dev
admin@ncs# conf
Entering configuration mode terminal
admin@ncs(config)# load merge ?
Possible completions:
  <filename/terminal>  .bash_history  .bashrc                             
  .profile             .ssh/          cml_devices.txt                     
  ncs-instance/        neds/          nso-6.3.linux.x86_64.installer.bin  
  nso-6.3/             
admin@ncs(config)# load merge cml_devices.txt ?
Possible completions:
  <cr>
admin@ncs(config)# load merge cml_devices.txt 
Loading.
1.07 KiB parsed in 0.26 sec (4.09 KiB/sec)
admin@ncs(config)# 
admin@ncs(config)# commit dry-run outformat cli-c 
cli-c {
    local-node {
        data devices device cml-core-rtr02
              address 10.251.13.204
              ssh host-key-verification none
              authgroup cmladmin
              device-type cli ned-id cisco-iosxr-cli-7.55
              device-type cli protocol ssh
              config
               admin
                exit-admin-config
               !
              !
             !
             devices device cml-dist-rtr01
              address 10.251.13.205
              ssh host-key-verification none
              authgroup cmladmin
              device-type cli ned-id cisco-ios-cli-6.106
              device-type cli protocol ssh
              config
               no service password-encryption
               no cable admission-control preempt priority-voice
               no cable qos permission create
               no cable qos permission update
               no cable qos permission modems
               no ip cef
               no ip forward-protocol nd
               no ipv6 cef
               no dot11 syslog
              !
             !
             devices device cml-dist-rtr02
              address 10.251.13.206
              ssh host-key-verification none
              authgroup cmladmin
              device-type cli ned-id cisco-ios-cli-6.106
              device-type cli protocol ssh
              config
               no service password-encryption
               no cable admission-control preempt priority-voice
               no cable qos permission create
               no cable qos permission update
               no cable qos permission modems
               no ip cef
               no ip forward-protocol nd
               no ipv6 cef
               no dot11 syslog
              !
             !
             devices device cml-dist-sw01
              address 10.251.13.207
              ssh host-key-verification none
              authgroup cmladmin
              device-type cli ned-id cisco-nx-cli-5.25
              device-type cli protocol ssh
              config
               no feature telnet
               no system auto-upgrade epld
               no logging monitor
               no logging module
               no logging console
              !
             !
             devices device cml-dist-sw02
              address 10.251.13.208
              ssh host-key-verification none
              authgroup cmladmin
              device-type cli ned-id cisco-nx-cli-5.25
              device-type cli protocol ssh
              config
               no feature telnet
               no system auto-upgrade epld
               no logging monitor
               no logging module
               no logging console
              !
             !
    }
}
admin@ncs(config)# 
admin@ncs(config)# commit label cml-devices-added
Commit complete.
admin@ncs(config)# 
```

Verify the list of devices.

```sh
admin@ncs# show devices list 
NAME            ADDRESS        DESCRIPTION  NED ID                ADMIN STATE        
-----------------------------------------------------------------------------------
cml-core-rtr01  10.251.13.203  -            cisco-iosxr-cli-7.55  unlocked           
cml-core-rtr02  10.251.13.204  -            cisco-iosxr-cli-7.55  southbound-locked  
cml-dist-rtr01  10.251.13.205  -            cisco-ios-cli-6.106   southbound-locked  
cml-dist-rtr02  10.251.13.206  -            cisco-ios-cli-6.106   southbound-locked  
cml-dist-sw01   10.251.13.207  -            cisco-nx-cli-5.25     southbound-locked  
cml-dist-sw02   10.251.13.208  -            cisco-nx-cli-5.25     southbound-locked  
admin@ncs# 
```

Notice that ADMIN STATE of the newly added devices are southbound-locked, so we need unlock them. 

```sh
admin@ncs(config)# devices device cml-core-rtr02 state admin-state unlocked ?
Possible completions:
  admin-state-description   Reason for the admin state.
  <cr>                      
admin@ncs(config-device-cml-core-rtr02)# commit dry-run 
cli {
    local-node {
        data  devices {
                  device cml-core-rtr02 {
                      state {
             +            admin-state unlocked;
                      }
                  }
              }
    }
}
admin@ncs(config-device-cml-core-rtr02)# commit 
Commit complete.
admin@ncs(config-device-cml-core-rtr02)# end
admin@ncs# show devices list 
NAME            ADDRESS        DESCRIPTION  NED ID                ADMIN STATE        
-----------------------------------------------------------------------------------
cml-core-rtr01  10.251.13.203  -            cisco-iosxr-cli-7.55  unlocked           
cml-core-rtr02  10.251.13.204  -            cisco-iosxr-cli-7.55  unlocked           
cml-dist-rtr01  10.251.13.205  -            cisco-ios-cli-6.106   southbound-locked  
cml-dist-rtr02  10.251.13.206  -            cisco-ios-cli-6.106   southbound-locked  
cml-dist-sw01   10.251.13.207  -            cisco-nx-cli-5.25     southbound-locked  
cml-dist-sw02   10.251.13.208  -            cisco-nx-cli-5.25     southbound-locked  
admin@ncs# 
admin@ncs# show devices brief 
NAME            ADDRESS        DESCRIPTION  NED ID                
----------------------------------------------------------------
cml-core-rtr01  10.251.13.203  -            cisco-iosxr-cli-7.55  
cml-core-rtr02  10.251.13.204  -            cisco-iosxr-cli-7.55  
cml-dist-rtr01  10.251.13.205  -            cisco-ios-cli-6.106   
cml-dist-rtr02  10.251.13.206  -            cisco-ios-cli-6.106   
cml-dist-sw01   10.251.13.207  -            cisco-nx-cli-5.25     
cml-dist-sw02   10.251.13.208  -            cisco-nx-cli-5.25     
admin@ncs# 
```

```sh
admin@ncs(config)# devices device cml-dist-rtr01 state admin-state unlocked 
admin@ncs(config-device-cml-dist-rtr01)# devices device cml-dist-rtr02 state admin-state unlocked
admin@ncs(config-device-cml-dist-rtr02)# devices device cml-dist-sw01 state admin-state unlocked 
admin@ncs(config-device-cml-dist-sw01)# devices device cml-dist-sw02 state admin-state unlocked
admin@ncs(config-device-cml-dist-sw02)#
admin@ncs(config-device-cml-dist-sw02)# commit dry-run outformat cli-c 
cli-c {
    local-node {
        data devices device cml-dist-rtr01
              state admin-state unlocked
             !
             devices device cml-dist-rtr02
              state admin-state unlocked
             !
             devices device cml-dist-sw01
              state admin-state unlocked
             !
             devices device cml-dist-sw02
              state admin-state unlocked
             !
    }
}
admin@ncs(config-device-cml-dist-sw02)# 
admin@ncs(config-device-cml-dist-sw02)# commit label cml-devices-unlocked
Commit complete.
admin@ncs(config-device-cml-dist-sw02)# end
admin@ncs# show devices list 
NAME            ADDRESS        DESCRIPTION  NED ID                ADMIN STATE  
-----------------------------------------------------------------------------
cml-core-rtr01  10.251.13.203  -            cisco-iosxr-cli-7.55  unlocked     
cml-core-rtr02  10.251.13.204  -            cisco-iosxr-cli-7.55  unlocked     
cml-dist-rtr01  10.251.13.205  -            cisco-ios-cli-6.106   unlocked     
cml-dist-rtr02  10.251.13.206  -            cisco-ios-cli-6.106   unlocked     
cml-dist-sw01   10.251.13.207  -            cisco-nx-cli-5.25     unlocked     
cml-dist-sw02   10.251.13.208  -            cisco-nx-cli-5.25     unlocked     
admin@ncs# 
```

##### Sync from the devices 

Before sync-from, you will only see the following config we created earlier. 

```sh
admin@ncs# show running-config devices device cml-core-rtr01 
devices device cml-core-rtr01
 address   10.251.13.203
 ssh host-key-verification none
 authgroup cmladmin
 device-type cli ned-id cisco-iosxr-cli-7.55
 device-type cli protocol ssh
 state admin-state unlocked
 config
  admin
   exit-admin-config
  !
 !
!
admin@ncs# show running-config devices device cml-core-rtr02
devices device cml-core-rtr02
 address   10.251.13.204
 ssh host-key-verification none
 authgroup cmladmin
 device-type cli ned-id cisco-iosxr-cli-7.55
 device-type cli protocol ssh
 state admin-state unlocked
 config
  admin
   exit-admin-config
  !
 !
!
```

Run the `sync-from`

```sh
admin@ncs# devices sync-from
sync-result {
    device cml-core-rtr01
    result true
}
sync-result {
    device cml-core-rtr02
    result true
}
sync-result {
    device cml-dist-rtr01
    result true
}
sync-result {
    device cml-dist-rtr02
    result true
}
sync-result {
    device cml-dist-sw01
    result true
}
sync-result {
    device cml-dist-sw02
    result true
}
admin@ncs# 
```

Now if you have run the following command on any of the above device, you will see the full config. 

`admin@ncs# show running-config devices device cml-core-rtr01`

##### Create Device Groups 

You may also create group of devices to manage them as per DC/Site or any other level hierarchy.

```sh
admin@ncs# con
Entering configuration mode terminal
admin@ncs(config)# devices device-group ?
% No entries found
Possible completions:
  <name:string>
admin@ncs(config)# devices device-group IOS-DEVICES
admin@ncs(config-device-group-IOS-DEVICES)# device-name cml-dist-rtr01
admin@ncs(config-device-group-IOS-DEVICES)# device-name cml-dist-rtr02
admin@ncs(config-device-group-IOS-DEVICES)# devices device-group IOSXR-DEVICES
admin@ncs(config-device-group-IOSXR-DEVICES)# device-name cml-core-rtr01
admin@ncs(config-device-group-IOSXR-DEVICES)# device-name cml-core-rtr02
admin@ncs(config-device-group-IOSXR-DEVICES)# devices device-group NXOS-DEVICES 
admin@ncs(config-device-group-NXOS-DEVICES)# device-name cml-dist-sw01         
admin@ncs(config-device-group-NXOS-DEVICES)# device-name cml-dist-sw02
admin@ncs(config-device-group-NXOS-DEVICES)# 
admin@ncs(config-device-group-NXOS-DEVICES)# commit dry-run outformat cli-c 
cli-c {
    local-node {
        data devices device-group IOS-DEVICES
              device-name [ cml-dist-rtr01 cml-dist-rtr02 ]
             !
             devices device-group IOSXR-DEVICES
              device-name [ cml-core-rtr01 cml-core-rtr02 ]
             !
             devices device-group NXOS-DEVICES
              device-name [ cml-dist-sw01 cml-dist-sw02 ]
             !
    }
}
admin@ncs(config-device-group-NXOS-DEVICES)# commit label group-devices
Commit complete.
admin@ncs(config-device-group-NXOS-DEVICES)# 
```
Now group all of the groups into another group CML-DEVICES 

```sh
admin@ncs# config 
Entering configuration mode terminal
admin@ncs(config)# devices device-group CML-DEVICES
admin@ncs(config-device-group-CML-DEVICES)# device-group 
Possible completions:
  CML-DEVICES  IOS-DEVICES  IOSXR-DEVICES  NXOS-DEVICES  [
admin@ncs(config-device-group-CML-DEVICES)# device-group IOS-DEVICES ?
Possible completions:
  device-name   Device within group
  location      Physical location of devices in the group
  <cr>          
admin@ncs(config-device-group-CML-DEVICES)# device-group IOS-DEVICES 
admin@ncs(config-device-group-CML-DEVICES)# device-group IOSXR-DEVICES
admin@ncs(config-device-group-CML-DEVICES)# device-group NXOS-DEVICES 
admin@ncs(config-device-group-CML-DEVICES)# commit dry-run outformat cli-c
cli-c {
    local-node {
        data devices device-group CML-DEVICES
              device-group [ IOS-DEVICES IOSXR-DEVICES NXOS-DEVICES ]
             !
    }
}
admin@ncs(config-device-group-CML-DEVICES)# commit label created-cml-dev-grp
Commit complete.
admin@ncs(config-device-group-CML-DEVICES)# 
```

Finally run the `check-sync` on the group level to check sync status against all the devices. 

```sh
admin@ncs# devices device-group CML-DEVICES check-sync
sync-result {
    device cml-core-rtr01
    result in-sync
}
sync-result {
    device cml-core-rtr02
    result in-sync
}
sync-result {
    device cml-dist-rtr01
    result in-sync
}
sync-result {
    device cml-dist-rtr02
    result in-sync
}
sync-result {
    device cml-dist-sw01
    result in-sync
}
sync-result {
    device cml-dist-sw02
    result in-sync
}
admin@ncs# 
```

##### Reference:

[Learn NSO: The Easy Way](https://developer.cisco.com/learning/labs/learn-nso-the-easy-way/populating-your-nso-instance/)