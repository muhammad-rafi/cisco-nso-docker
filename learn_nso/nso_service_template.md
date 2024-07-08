#### Template-based service

cd ~/ncs-instance/packages
ncs-make-package --service-skeleton template loopback-service
cd loopback-service
tree

```sh
root@cisco-nso-dev:~# cd ~/ncs-instance/packages
root@cisco-nso-dev:~/ncs-instance/packages# 
root@cisco-nso-dev:~/ncs-instance/packages# ncs-make-package --service-skeleton template loopback-service
root@cisco-nso-dev:~/ncs-instance/packages# cd loopback-service/
root@cisco-nso-dev:~/ncs-instance/packages/loopback-service# tree
.
|-- package-meta-data.xml
|-- src
|   |-- Makefile
|   `-- yang
|       `-- loopback-service.yang
|-- templates
|   `-- loopback-service-template.xml
`-- test
    |-- Makefile
    `-- internal
        |-- Makefile
        `-- lux
            |-- Makefile
            `-- basic
                |-- Makefile
                `-- run.lux

7 directories, 9 files
root@cisco-nso-dev:~/ncs-instance/packages/loopback-service# 
```

There are two following main files, you need see and edit from the service template
- loopback-service.yang
- loopback-service-template.xml

To configure the loopback interface for  we need the followings
- Loopback interface name 
- IP Address (ipv4/ipv6 in this case)
- Subnet mask
- Description (optional)
- State (up or down)

Lets go to the nso and create a loopback interface configure for Cisco IOS device and check the output in XML format 
to get the XML output for the service template. 

```c
interface Loopback99
 description created by nso
 ip address 192.0.2.1 255.255.255.255
 ipv6 address 2001:db8::1/128
 shutdown
```

```sh
root@cisco-nso-dev:~/ncs-instance/packages/loopback-service# ncs_cli -C -u admin

User admin last logged in 2024-06-18T12:39:27.271447+00:00, to cisco-nso-dev, from 127.0.0.1 using cli-console
admin connected from 127.0.0.1 using console on cisco-nso-dev
admin@ncs# config 
Entering configuration mode terminal
admin@ncs(config)#
admin@ncs(config)# devices device cml-dist-rtr01 config interface Loopback 99 
admin@ncs(config-if)# description created by nso
admin@ncs(config-if)# ip address 192.0.2.1 255.255.255.255
admin@ncs(config-if)# ipv6 address 2001:db8::1/128
admin@ncs(config-if)# shutdown
admin@ncs(config-if)# top
admin@ncs(config)# commit dry-run outformat xml
result-xml {
    local-node {
        data <devices xmlns="http://tail-f.com/ns/ncs">
               <device>
                 <name>cml-dist-rtr01</name>
                 <config>
                   <interface xmlns="urn:ios">
                     <Loopback>
                       <name>99</name>
                       <description>created by nso</description>
                       <ip>
                         <address>
                           <primary>
                             <address>192.0.2.1</address>
                             <mask>255.255.255.255</mask>
                           </primary>
                         </address>
                       </ip>
                       <ipv6>
                         <address>
                           <prefix-list>
                             <prefix>2001:db8::1/128</prefix>
                           </prefix-list>
                         </address>
                       </ipv6>
                       <shutdown/>
                     </Loopback>
                   </interface>
                 </config>
               </device>
             </devices>
    }
}
admin@ncs(config)# 
admin@ncs(config)# abort
admin@ncs# exit
root@cisco-nso-dev:~/ncs-instance/packages/loopback-service# 
```

After you have the above output, identify the hardcoded values between the <config> tags and convert them into variable. 
- <name>99</name> --> intf_name
- <description>nso service</description> --> intf_desc
- <address>99.99.99.99</address> --> ipv4_addr
- <mask>255.255.255.255</mask> --> ipv4_mask
- <prefix>2001:db8::1/128</prefix> ipv6_prefix
- <shutdown/> intf_state

Now, edit the service template xml file `loopback-service-template.xml` and place these variables after the device tag.

Note: use {/var} where var is the variable name. 

```sh
<config>
  <interface xmlns="urn:ios">
    <Loopback>
      <name>{/intf-id}</name>
      <description>{/intf-desc}</description>
      <ip>
        <address>
          <primary>
            <address>{/ipv4-addr}</address>
            <mask>{/ipv4-mask}</mask>
          </primary>
        </address>
      </ip>
      <ipv6>
        <address>
          <prefix-list>
            <prefix>{/ipv6-prefix}</prefix>
          </prefix-list>
        </address>
      </ipv6>
      <?if {/enabled = 'false'}?>
      <shutdown/>
      <?end?>
    </Loopback>
  </interface>
</config>
```

```sh
root@cisco-nso-dev:~/ncs-instance/packages/loopback-service# vi templates/loopback-service-template.xml 

<config-template xmlns="http://tail-f.com/ns/config/1.0"
                 servicepoint="loopback-service">
  <devices xmlns="http://tail-f.com/ns/ncs">
    <device>
      <!--
          Select the devices from some data structure in the service
          model. In this skeleton the devices are specified in a leaf-list.
          Select all devices in that leaf-list:
      -->
      <name>{/device}</name>
      <config>
        <!--
            Add device-specific parameters here.
            In this skeleton the service has a leaf "dummy"; use that
            to set something on the device e.g.:
            <ip-address-on-device>{/dummy}</ip-address-on-device>
        -->
        <interface xmlns="urn:ios">
          <Loopback>
            <name>{/intf-id}</name>
            <description>{/intf-desc}</description>
            <ip>
              <address>
                <primary>
                  <address>{/ipv4-addr}</address>
                  <mask>{/ipv4-mask}</mask>
                </primary>
              </address>
            </ip>
            <ipv6>
              <address>
                <prefix-list>
                  <prefix>{/ipv6-prefix}</prefix>
                </prefix-list>
              </address>
            </ipv6>
            <?if {/enabled = 'false'}?>
            <shutdown/>
            <?end ?>
          </Loopback>
        </interface>
      </config>
    </device>
  </devices>
</config-template>
```
Next step is to edit the `loopback-service.yang` under src/yang directory to create these variables used in XML template.
Start editing from the tag `// replace with your own stuff here`

```sh
root@cisco-nso-dev:~/ncs-instance/packages/loopback-service# vi src/yang/loopback-service.yang 

module loopback-service {
  namespace "http://com/example/loopbackservice";
  prefix loopback-service;

  import ietf-inet-types {
    prefix inet;
  }
  import tailf-ncs {
    prefix ncs;
  }

  import tailf-common {
    prefix tailf;
  }
  
  list loopback-service {
    key name;

    uses ncs:service-data;
    ncs:servicepoint "loopback-service";

    leaf name {
      tailf:info "Loopback Service Instance Name";
      type string;
    }

    // may replace this with other ways of refering to the devices.
    leaf-list device {
      type leafref {
        path "/ncs:devices/ncs:device/ncs:name";
      }
    }

    // replace with your own stuff here
    leaf intf-id {
      tailf:info "Loopback interface ID";
      type uint32;
      mandatory true;
    }

    leaf intf-desc {
      tailf:info "Interface description";
      type string;
    }

    leaf ipv4-addr {
      tailf:info "IPv4 address";
      type inet:ipv4-address;
    }

    leaf ipv4-mask {
      tailf:info "IPv4 subnet mask";
      type string {
        pattern '((255\.(0|128|192|224|240|248|252|254|255)\.0\.0)|' +
                '(255\.(255\.(0|128|192|224|240|248|252|254|255)\.0))|' +
                '(255\.(255\.(255\.(0|128|192|224|240|248|252|254|255))))|' +
                '(255\.(255\.(255\.(255)))))';
      }
    }

    leaf ipv6-prefix {
      tailf:info "IPv6 prefix";
      type inet:ipv6-prefix;
    }

    leaf enabled {
      tailf:info "Enable loopback interface. If false, interface will be shutdown.";
      type boolean;
      default true;
    }
  }
}
```

Finally run the `make` command to compile the service template and check if there are any errors 

```sh
root@cisco-nso-dev:~/ncs-instance/packages/loopback-service/src# make clean && make
rm -rf ../load-dir
mkdir -p ../load-dir
/root/nso-6.3/bin/ncsc `ls loopback-service-ann.yang  > /dev/null 2>&1 && echo "-a loopback-service-ann.yang"` \
        --fail-on-warnings \
         \
        -c -o ../load-dir/loopback-service.fxs yang/loopback-service.yang
yang/loopback-service.yang:19: error: undefined prefix tailf
yang/loopback-service.yang:32: error: undefined prefix tailf
yang/loopback-service.yang:38: error: undefined prefix tailf
yang/loopback-service.yang:43: error: undefined prefix tailf
yang/loopback-service.yang:48: error: undefined prefix tailf
make: *** [Makefile:26: ../load-dir/loopback-service.fxs] Error 1
```

The reason I was getting the above error is because I was missing the `tailf-common` module, so I added that module and compilation is OK.

Added 
```sh
  import tailf-common {
    prefix tailf;
  }
```

```sh
root@cisco-nso-dev:~/ncs-instance/packages/loopback-service/src# make clean && make
rm -rf ../load-dir
mkdir -p ../load-dir
/root/nso-6.3/bin/ncsc `ls loopback-service-ann.yang  > /dev/null 2>&1 && echo "-a loopback-service-ann.yang"` \
        --fail-on-warnings \
         \
        -c -o ../load-dir/loopback-service.fxs yang/loopback-service.yang
root@cisco-nso-dev:~/ncs-instance/packages/loopback-service/src# 
```

Final step is to do the package reload via NSO cli, it may take few minutes, so be patient.

```sh
root@cisco-nso-dev:~/ncs-instance/packages# ncs_cli -C -u admin

User admin last logged in 2024-06-18T13:10:16.778447+00:00, to cisco-nso-dev, from 127.0.0.1 using cli-console
admin connected from 127.0.0.1 using console on cisco-nso-dev
admin@ncs# packages reload 

>>> System upgrade is starting.
>>> Sessions in configure mode must exit to operational mode.
>>> No configuration changes can be performed until upgrade has completed.
>>> System upgrade has completed successfully.
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
reload-result {
    package loopback-service
    result true
}
admin@ncs# 
System message at 2024-06-18 15:06:41...
    Subsystem stopped: ncs-dp-4-cisco-asa-cli-6.18:ASADp
admin@ncs# 
System message at 2024-06-18 15:06:41...
    Subsystem stopped: ncs-dp-5-cisco-ios-cli-6.106:IOSDp
admin@ncs# 
System message at 2024-06-18 15:06:41...
    Subsystem stopped: ncs-dp-6-cisco-nx-cli-5.25:NexusDp
admin@ncs# 
System message at 2024-06-18 15:06:41...
    Subsystem started: ncs-dp-7-cisco-asa-cli-6.18:ASADp
admin@ncs# 
System message at 2024-06-18 15:06:41...
    Subsystem started: ncs-dp-8-cisco-ios-cli-6.106:IOSDp
admin@ncs# 
System message at 2024-06-18 15:06:41...
    Subsystem started: ncs-dp-9-cisco-nx-cli-5.25:NexusDp
admin@ncs# 
```

Notice the loopback-service output is true from above. 

```sh
reload-result {
    package loopback-service
    result true
}
```

```sh
admin@ncs# show packages package package-version 
packages package cisco-asa-cli-6.18
 package-version 6.18.14
packages package cisco-ios-cli-6.106
 package-version 6.106.8
packages package cisco-iosxr-cli-7.55
 package-version 7.55.7
packages package cisco-nx-cli-5.25
 package-version 5.25.11
packages package loopback-service
 package-version 1.0
admin@ncs# 
```

Next step you can do is to configure IOS device via NSO with this loopback service we created.
```c
loopback-service ios-lb-service device cml-dist-rtr01 intf-id 99 intf-desc "created by nso" ipv4-addr 192.0.2.1 ipv4-mask 255.255.255.255 ipv6-prefix 2001:db8::1/128
```

```sh
admin@ncs(config)# loopback-service ios-lb-service device cml-dist-rtr01 intf-id 99 intf-desc "created by nso" ipv4-addr 192.0.2.1 ipv4-mask 255.255.255.255 ipv6-prefix 2001:db8::1/128
admin@ncs(config-loopback-service-ios-lb-service)# commit dry-run 
cli {
    local-node {
        data  devices {
                  device cml-dist-rtr01 {
                      config {
                          interface {
             +                Loopback 99 {
             +                    description "created by nso";
             +                    ip {
             +                        address {
             +                            primary {
             +                                address 192.0.2.1;
             +                                mask 255.255.255.255;
             +                            }
             +                        }
             +                    }
             +                    ipv6 {
             +                        address {
             +                            prefix-list 2001:db8::1/128;
             +                        }
             +                    }
             +                }
                          }
                      }
                  }
              }
             +loopback-service ios-lb-service {
             +    device [ cml-dist-rtr01 ];
             +    intf-id 99;
             +    intf-desc "created by nso";
             +    ipv4-addr 192.0.2.1;
             +    ipv4-mask 255.255.255.255;
             +    ipv6-prefix 2001:db8::1/128;
             +}
    }
}
admin@ncs(config-loopback-service-ios-lb-service)# 
```

You also check this in the XML format 

```xml
admin@ncs(config-loopback-service-ios-lb-service)# commit dry-run outformat xml 
result-xml {
    local-node {
        data <devices xmlns="http://tail-f.com/ns/ncs">
               <device>
                 <name>cml-dist-rtr01</name>
                 <config>
                   <interface xmlns="urn:ios">
                     <Loopback>
                       <name>99</name>
                       <description>created by nso</description>
                       <ip>
                         <address>
                           <primary>
                             <address>192.0.2.1</address>
                             <mask>255.255.255.255</mask>
                           </primary>
                         </address>
                       </ip>
                       <ipv6>
                         <address>
                           <prefix-list>
                             <prefix>2001:db8::1/128</prefix>
                           </prefix-list>
                         </address>
                       </ipv6>
                     </Loopback>
                   </interface>
                 </config>
               </device>
             </devices>
             <loopback-service xmlns="http://com/example/loopbackservice">
               <name>ios-lb-service</name>
               <device>cml-dist-rtr01</device>
               <intf-id>99</intf-id>
               <intf-desc>created by nso</intf-desc>
               <ipv4-addr>192.0.2.1</ipv4-addr>
               <ipv4-mask>255.255.255.255</ipv4-mask>
               <ipv6-prefix>2001:db8::1/128</ipv6-prefix>
             </loopback-service>
    }
}
admin@ncs(config-loopback-service-ios-lb-service)# 
```

Before apply the service, let check what loopbacks we have on the device

```sh
cml-dist-rtr01#sh ip int br | i Loop
Loopback0              10.0.0.5        YES NVRAM  up                    up      
cml-dist-rtr01#
```

Now, lets apply the config via NSO and check the device config again

```sh
admin@ncs(config-loopback-service-ios-lb-service)# commit label lo99-cml-dist-rtr01
Commit complete.
admin@ncs(config-loopback-service-ios-lb-service)# 
```

As you can new Loopback 99 has been created on the device 
```sh
cml-dist-rtr01#sh ip int br | i Loop
Loopback0              10.0.0.5        YES NVRAM  up                    up      
Loopback99             192.0.2.1       YES manual up                    up      
cml-dist-rtr01#
cml-dist-rtr01#sh run int lo99
Building configuration...

Current configuration : 124 bytes
!
interface Loopback99
 description created by nso
 ip address 192.0.2.1 255.255.255.255
 ipv6 address 2001:DB8::1/128
end

cml-dist-rtr01#
```

You can also verify via NSO 

```sh
admin@ncs(config-loopback-service-ios-lb-service)# commit label lo99-cml-dist-rtr01
Commit complete.
admin@ncs(config-loopback-service-ios-lb-service)# top
admin@ncs(config)# show full-configuration devices device cml-dist-rtr01 config ios:interface Loopback 99 
devices device cml-dist-rtr01
 config
  interface Loopback99
   description created by nso
   ip address 192.0.2.1 255.255.255.255
   ipv6 address 2001:db8::1/128
   no shutdown
  exit
 !
!
```

Lets's rollback the configuration for clean up. You can simply rollback last configuration by entering the 'rollback configuration' command and run the 'dryrun' to verify.

```sh
admin@ncs(config)# rollback configuration ?
Possible completions:
  10001   2024-07-07 13:19:29 by system via system
  10003   2024-07-07 13:28:47 by system via system
  10004   2024-07-07 13:50:05 by admin via cli label authgroup-cmladmin-added
  10005   2024-07-07 13:54:25 by admin via cli label cml-devices-added
  10006   2024-07-07 13:58:23 by admin via cli label cml-devices-added
  10007   2024-07-07 14:01:59 by admin via cli label unlocked-cml-devices
  10008   2024-07-07 14:02:55 by admin via cli
  10009   2024-07-07 14:02:56 by admin via cli
  10010   2024-07-07 14:02:56 by admin via cli
  10011   2024-07-07 14:02:58 by admin via cli
  10012   2024-07-07 14:02:58 by admin via cli
  10013   2024-07-07 14:06:35 by admin via cli
  10015   2024-07-08 11:06:08 by admin via cli
  10016   2024-07-08 11:07:04 by admin via cli
  10017   2024-07-08 11:08:04 by admin via cli
  10018   2024-07-08 11:08:46 by admin via cli
  10020   2024-07-08 11:40:12 by admin via cli
  10021   2024-07-08 11:41:04 by admin via cli
  10022   2024-07-08 12:03:03 by admin via cli label lo99-cml-dist-rtr01
  <cr>    latest
admin@ncs(config)# rollback configuration 
admin@ncs(config)# commit dry-run outformat cli-c
cli-c {
    local-node {
        data no loopback-service ios-lb-service
             devices device cml-dist-rtr01
              config
               no interface Loopback99
              !
              no services service /loopback-service[name='ios-lb-service']
             !
    }
}
admin@ncs(config)# commit
Commit complete.
admin@ncs(config)# 
```

Verify Loopback 99 has been removed from the cml-dist-rtr01.

```sh
admin@ncs(config)# show full-configuration devices device cml-dist-rtr01 config ios:interface Loopback 99 
----------------------------------------------------------------------------------------------^
syntax error: unknown argument
admin@ncs(config)# 
admin@ncs(config)# show full-configuration devices device cml-dist-rtr01 config ios:interface Loopback   
devices device cml-dist-rtr01
 config
  interface Loopback0
   ip address 10.0.0.5 255.255.255.255
   ip ospf 1 area 0
   ip ospf network point-to-point
   no shutdown
  exit
 !
!
```

As you can see, Loopback 99 has been removed from the cml-dist-rtr01.

Reference:
[Introduction to NSO Service Development](https://developer.cisco.com/learning/modules/nso-service-dev/service-dev-101/introduction/)

[Create a Template-Based Service](https://developer.cisco.com/learning/modules/nso-service-dev/service-dev-101/create-a-template-based-service/)

[NSO Nano Service Development](https://developer.cisco.com/learning/labs/service-dev-301/introduction/)
