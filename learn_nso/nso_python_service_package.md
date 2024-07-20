# Create NSO `python-and-template` service package

### What is NSO Service Package 

In Cisco Network Services Orchestrator (NSO), a Python and Template-based service refers to a method of creating network services where the service logic is implemented using Python scripts and device configurations are generated using templates. This approach leverages the flexibility of Python for custom logic and the power of templates for generating standardized configurations.

Key Components of python-and-template-based NSO Services

- YANG Model: Defines the structure of the service data model.
- Python Scripts: Implement the service logic and interact with the YANG model and templates.
- Templates: Define the configuration that will be applied to devices. These are often written in XML.

In this example, I am going to create `python-and-template` based service package for BGP Max Prefix Limit, named as `bgp-prefix-limit-service`, however there are some other options available to create a service package. You can check out the other service package options with below command using `-h` or `--help` flag.

```sh
[root@devnetbox ~]# ncs-make-package --help
```

To create python-and-template-based NSO Services, follow the step below;

- Generate the Service Skeleton: Use the ncs-make-package tool to create a skeleton service package.
- Define the YANG Model: Create a YANG model that describes the service and its parameters.
- Implement the Python Service Logic: Write Python scripts to handle service creation, modification, and deletion.
- Create Configuration Templates: Write templates that will be used to generate device configurations.
- Compile and Deploy the Service Package: Compile the YANG model and deploy the package to NSO.

__Step1: Login to NSO or connect to the NSO docker container.__

```sh
[root@devnetbox ~]# docker exec -it cisco-nso-dev bash
root@cisco-nso-dev:~# 
```

__Step2: Run ncs-make-package with --service-skeleton which generates boilerplate service package code.__

`ncs-make-package --no-java --service-skeleton python-and-template <package-name> --dest DIR`

 or 
 
`ncs-make-package --service-skeleton python-and-template <package-name>`

ncs-make-package --no-java --service-skeleton python-and-template bgp-prefix-limit-service --dest ${NCS_RUN_DIR}/packages/bgp-prefix-limit-service

make sure you have already created this environment variable ${NCS_RUN_DIR} which could be '~/nso-instance', but in my case I have it as '~/ncs-instance'

```sh
root@cisco-nso-dev:~# ncs-make-package --no-java --service-skeleton python-and-template bgp-prefix-limit-service --dest ${NCS_RUN_DIR}/packages/bgp-prefix-limit-service
root@cisco-nso-dev:~# 
root@cisco-nso-dev:~# ls -l ncs-instance/packages/
total 0
drwxr-xr-x. 6 root root 103 Jul  4 10:21 bgp-prefix-limit-service
lrwxrwxrwx. 1 root root  46 Jun 17 11:54 cisco-asa-cli-6.18 -> /root/nso-6.3/packages/neds/cisco-asa-cli-6.18
lrwxrwxrwx. 1 root root  47 Jun 17 11:54 cisco-ios-cli-6.106 -> /root/nso-6.3/packages/neds/cisco-ios-cli-6.106
lrwxrwxrwx. 1 root root  48 Jun 17 11:54 cisco-iosxr-cli-7.55 -> /root/nso-6.3/packages/neds/cisco-iosxr-cli-7.55
lrwxrwxrwx. 1 root root  45 Jun 17 11:54 cisco-nx-cli-5.25 -> /root/nso-6.3/packages/neds/cisco-nx-cli-5.25
drwxr-xr-x. 6 root root  91 Jun 18 16:31 loopback-service
root@cisco-nso-dev:~# 
```

As you can see new package 'bgp-prefix-limit-service' has been created, let's see the file structure for the package using 'tree'

```sh
root@cisco-nso-dev:~# tree ${NCS_RUN_DIR}/packages/bgp-prefix-limit-service
/root/ncs-instance/packages/bgp-prefix-limit-service
|-- README
|-- package-meta-data.xml
|-- python
|   `-- bgp_prefix_limit_service
|       |-- __init__.py
|       `-- main.py
|-- src
|   |-- Makefile
|   `-- yang
|       `-- bgp-prefix-limit-service.yang
|-- templates
|   `-- bgp-prefix-limit-service-template.xml
`-- test
    |-- Makefile
    `-- internal
        |-- Makefile
        `-- lux
            |-- Makefile
            `-- service
                |-- Makefile
                |-- dummy-device.xml
                |-- dummy-service.xml
                |-- pyvm.xml
                `-- run.lux

9 directories, 15 files
root@cisco-nso-dev:~# 
```

Here are following three files we will be working with to create this package. 

- /bgp-prefix-limit-service/src/yang/bgp-prefix-limit-service.yang (YANG Model)
- /bgp-prefix-limit-service/templates/bgp-prefix-limit-service-template.xml (XML Template for device configuration)
- /bgp-prefix-limit-service/python/bgp_prefix_limit_service/main.py

__Step3: Create/Edit YANG Model for the service package__

As mentioned above, here we will be editing the `/bgp-prefix-limit-service/src/yang/bgp-prefix-limit-service.yang`. Let's see the current content of this file. 

```sh
root@cisco-nso-dev:~# cat ${NCS_RUN_DIR}/packages/bgp-prefix-limit-service/src/yang/bgp-prefix-limit-service.yang 
module bgp-prefix-limit-service {

  namespace "http://example.com/bgp-prefix-limit-service";
  prefix bgp-prefix-limit-service;

  import ietf-inet-types {
    prefix inet;
  }
  import tailf-common {
    prefix tailf;
  }
  import tailf-ncs {
    prefix ncs;
  }

  description
    "Bla bla...";

  revision 2016-01-01 {
    description
      "Initial revision.";
  }

  list bgp-prefix-limit-service {
    description "This is an RFS skeleton service";

    key name;
    leaf name {
      tailf:info "Unique service id";
      tailf:cli-allow-range;
      type string;
    }

    uses ncs:service-data;
    ncs:servicepoint bgp-prefix-limit-service-servicepoint;

    // may replace this with other ways of referring to the devices.
    leaf-list device {
      type leafref {
        path "/ncs:devices/ncs:device/ncs:name";
      }
    }

    // replace with your own stuff here
    leaf dummy {
      type inet:ipv4-address;
    }
  }
}
```

Notice `// replace with your own stuff here`, so we need to edit this file from here to add our required configuration parameters. 

So, we need to first think about what we need in this service package to be parameterized as variables. Since I am creating this service package for BGP maximum prefix limit, therefore, I like to have following in my YANG model. 

- List of bgp neighbors, where we will be setting bgp prefix limit
- bgp neighbor address
- bgp neighbor AS number
- bgp neighbor description (can be optional)
- bgp address family (can be ipv4 or ipv6)
- bgp neighbor maximum prefix limit we need to set 
- bgp neighbor prefix threshold we need to set (can be optional)

You may notice, I did not add the 'BGP local AS' here, as I will be hard coding the local AS, since we cannot have more than one instance BGP running on a device. However, it can also be parameterized as variable. 

Based on the above parameter, we can map them to YANG nodes types. 

- List of bgp neighbors <--> List 
- bgp neighbor address <--> Leaf
- bgp neighbor AS number <--> Leaf
- bgp neighbor description (can be optional) <--> Leaf
- bgp address family (can be ipv4 or ipv6) <--> Leaf with Choice/Cases
- bgp neighbor maximum prefix limit we need to set <--> Leaf
- bgp neighbor prefix threshold we need to set (can be optional) <--> Leaf

Let's edit the `bgp-prefix-limit-service.yang` and add our variables in there. 

```json
module bgp-prefix-limit-service {
  namespace "http://example.com/bgp-prefix-limit-service";
  prefix bgp-prefix-limit-service;

  import ietf-inet-types {
    prefix inet;
  }
  
  import tailf-common {
    prefix tailf;
  }

  import tailf-ncs {
    prefix ncs;
  }

  description 
    "BGP Max Prefix Limit Service YANG Model";

  revision 2024-07-05 {
    description
      "Initial revision.";
  }

  list bgp-prefix-limit-service {
    description "BGP Max Prefix Limit Service Configuration";
    key name;

    leaf name {
      tailf:info "Unique service id";
      tailf:cli-allow-range;
      type string;
    }

    uses ncs:service-data;
    ncs:servicepoint bgp-prefix-limit-service-servicepoint;

    leaf device {
      type leafref {
        path "/ncs:devices/ncs:device/ncs:name";
      }
    }

    list neighbors {
      tailf:info "BGP Neighbor Configuration";
      key neighbor-address;
      description "List of BGP neighbors";

      leaf neighbor-address {
        tailf:info "IPv4 or IPv6 Neighbor Address";
        type inet:ip-address;
        mandatory true;
        description "BGP Neighbor IP Address";
      }

      leaf description {
        tailf:info "Description for BGP Neighbor(optional)";
        type string;
        description "BGP Neighbor description";
      }

      leaf remote-as {
        tailf:info "Remote BGP AS number";
        type uint32;
        mandatory true;
        description "Remote BGP AS number";
      }

      choice address-family {
        mandatory true;
        description "Address family for the BGP neighbor";

        case ipv4 {
          leaf ipv4-unicast {
            tailf:info "IPv4 unicast address family";
            type empty;
            description "IPv4 unicast address family";
          }
        }
        case ipv6 {
          leaf ipv6-unicast {
            tailf:info "IPv6 unicast address family";
            type empty;
            description "IPv6 unicast address family";
          }
        }
      }

      leaf prefix-limit {
        tailf:info "Maximum Prefix Limit for BGP Neighbor";
        type uint32;
        mandatory true;
        description "Max Prefix limit";
      }

      leaf prefix-threshold {
        tailf:info "BGP Prefix threshold, default is 75";
        type uint8 {
            range '1..100';
        }
        default 75;
        description "Prefix threshold percentage";
      }
    }
  }
}
```

Now, we our YANG model has been completed, Let's move on the Python script to work with the variables coming from this YANG model.

__Step4: Create/Edit Python script for the service package__

You need to edit the python script which is generated by `ncs-make-package --service-skeleton` command under the `root@cisco-nso-dev:~# vi ${NCS_RUN_DIR}/packages/bgp-prefix-limit-service/python/bgp_prefix_limit_service/main.py`

Again like, YANG model, there is boiler plate available for you and you just need to add your logic in to this python script. Here is the full version of my python code. 

```python
# -*- mode: python; python-indent: 4 -*-
import ncs
from ncs.application import Service


# ------------------------
# SERVICE CALLBACK EXAMPLE
# ------------------------
class ServiceCallbacks(Service):

    # The create() callback is invoked inside NCS FASTMAP and
    # must always exist.
    @Service.create
    def cb_create(self, tctx, root, service, proplist):
        self.log.info('Service create(service=', service._path, ')')

        vars = ncs.template.Variables()
        vars.add('LOCAL_AS', '65001')
        template = ncs.template.Template(service)

        for neighbor in service.neighbors:
            vars.add('NEIGHBOR_ADDRESS', neighbor.neighbor_address)
            vars.add('REMOTE_AS', neighbor.remote_as)
            vars.add('PREFIX_LIMIT', neighbor.prefix_limit)
            vars.add('PREFIX_THRESHOLD', neighbor.prefix_threshold)
            
            # Add the optional description if it exists
            if hasattr(neighbor, 'description'):
                vars.add('DESCRIPTION', neighbor.description)

            # Handle address-family specific configuration
            if hasattr(neighbor, 'ipv4_unicast'):
                vars.add('ADDRESS_FAMILY', 'ipv4')
            elif hasattr(neighbor, 'ipv6_unicast'):
                vars.add('ADDRESS_FAMILY', 'ipv6')

            # Apply the template
            template.apply('bgp-prefix-limit-service-template', vars)
                
    # The pre_modification() and post_modification() callbacks are optional,
    # and are invoked outside FASTMAP. pre_modification() is invoked before
    # create, update, or delete of the service, as indicated by the enum
    # ncs_service_operation op parameter. Conversely
    # post_modification() is invoked after create, update, or delete
    # of the service. These functions can be useful e.g. for
    # allocations that should be stored and existing also when the
    # service instance is removed.

    # @Service.pre_modification
    # def cb_pre_modification(self, tctx, op, kp, root, proplist):
    #     self.log.info('Service premod(service=', kp, ')')

    # @Service.post_modification
    # def cb_post_modification(self, tctx, op, kp, root, proplist):
    #     self.log.info('Service postmod(service=', kp, ')')


# ---------------------------------------------
# COMPONENT THREAD THAT WILL BE STARTED BY NCS.
# ---------------------------------------------
class Main(ncs.application.Application):
    def setup(self):
        # The application class sets up logging for us. It is accessible
        # through 'self.log' and is a ncs.log.Log instance.
        self.log.info('Main RUNNING')

        # Service callbacks require a registration for a 'service point',
        # as specified in the corresponding data model.
        #
        self.register_service('bgp-prefix-limit-service-servicepoint', ServiceCallbacks)

        # If we registered any callback(s) above, the Application class
        # took care of creating a daemon (related to the service/action point).

        # When this setup method is finished, all registrations are
        # considered done and the application is 'started'.

    def teardown(self):
        # When the application is finished (which would happen if NCS went
        # down, packages were reloaded or some error occurred) this teardown
        # method will be called.

        self.log.info('Main FINISHED')
```

From the above python script, here is what I have added in this python script. 

```python
        vars = ncs.template.Variables()
        vars.add('LOCAL_AS', '65001')
        template = ncs.template.Template(service)

        for neighbor in service.neighbors:
            vars.add('NEIGHBOR_ADDRESS', neighbor.neighbor_address)
            vars.add('REMOTE_AS', neighbor.remote_as)
            vars.add('PREFIX_LIMIT', neighbor.prefix_limit)
            vars.add('PREFIX_THRESHOLD', neighbor.prefix_threshold)
            
            # Add the optional description if it exists
            if hasattr(neighbor, 'description'):
                vars.add('DESCRIPTION', neighbor.description)

            # Handle address-family specific configuration
            if hasattr(neighbor, 'ipv4_unicast'):
                vars.add('ADDRESS_FAMILY', 'ipv4')
            elif hasattr(neighbor, 'ipv6_unicast'):
                vars.add('ADDRESS_FAMILY', 'ipv6')

            # Apply the template
            template.apply('bgp-prefix-limit-service-template', vars)
```

This is simple python logic, where I am iterating over the list of neighbor and assigning the variable names to the YANG nodes parameter we defined in the YANG model earlier. Notice, as I mentioned above, I have hard coded the Local AS number as '65001'.

You may also notice that, in python script, parameter coming from the YANG model with '-' are being replaced as '_' as python doesn't support '-' or hyphen in the variable name.

```sh
>>> foo-bar = 'baz'
  File "<stdin>", line 1
    foo-bar = 'baz'
    ^^^^^^^
SyntaxError: cannot assign to expression here. Maybe you meant '==' instead of '='?
>>> foo-bar == 'baz'
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
NameError: name 'foo' is not defined
>>> 
```

Finally we need to move to final XML file. 

__Step4: Create/Edit XML config template for the service package__

Before we can create the XML, first we need to check what payload will be that can be pushed out to the device via CLI. so we need to go to the NSO and try to generate the config and check the output in XML format. 

```sh
root@cisco-nso-dev:~# ncs_cli -C -u admin

User admin last logged in 2024-07-08T23:42:49.534506+00:00, to cisco-nso-dev, from 10.209.220.140 using webui-http
admin connected from 127.0.0.1 using console on cisco-nso-dev
admin@ncs# config 
Entering configuration mode terminal
admin@ncs(config)#
admin@ncs(config)# devices device cml-core-rtr01 config router bgp 65001 neighbor 1.1.1.1 remote-as 200 address-family ipv4 unicast maximum-prefix 100 75 
admin@ncs(config-bgp-nbr-af)# commit dry-run outformat xml 
result-xml {
    local-node {
        data <devices xmlns="http://tail-f.com/ns/ncs">
               <device>
                 <name>cml-core-rtr01</name>
                 <config>
                   <router xmlns="http://tail-f.com/ned/cisco-ios-xr">
                     <bgp>
                       <bgp-no-instance>
                         <id>65001</id>
                         <neighbor>
                           <id>1.1.1.1</id>
                           <remote-as>200</remote-as>
                           <address-family>
                             <ipv4>
                               <unicast>
                                 <maximum-prefix>
                                   <max-prefix-limit>100</max-prefix-limit>
                                   <threshold>75</threshold>
                                 </maximum-prefix>
                               </unicast>
                             </ipv4>
                           </address-family>
                         </neighbor>
                       </bgp-no-instance>
                     </bgp>
                   </router>
                 </config>
               </device>
             </devices>
    }
}
admin@ncs(config-bgp-nbr-af)# abort
admin@ncs# 
```

As you can see from above, I generated the config only for ipv4 address-family, however it will be same for ipv6 as well. so we will copy this output between `<config>` tags, and will paste under our XML template between the `<config>` tags.

```xml
root@cisco-nso-dev:~# vi ${NCS_RUN_DIR}/packages/bgp-prefix-limit-service/templates/bgp-prefix-limit-service-template.xml 

<config-template xmlns="http://tail-f.com/ns/config/1.0">
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
            In this skeleton the, java code sets a variable DUMMY, use it
            to set something on the device e.g.:
            <ip-address-on-device>{$DUMMY}</ip-address-on-device>
        -->
        <router xmlns="http://tail-f.com/ned/cisco-ios-xr" tags="nocreate">
          <bgp>
            <bgp-no-instance>
              <id>{$LOCAL_AS}</id>
              <neighbor tags="merge">
                <id>{$NEIGHBOR_ADDRESS}</id>
                <remote-as>{$REMOTE_AS}</remote-as>
                <!-- Conditional description -->
                <?if {$DESCRIPTION != 'None'} ?>
                <description>{$DESCRIPTION}</description>
                <?end ?>
                <!-- Address family conditional -->
                <address-family>
                  <ipv4 when="{$ADDRESS_FAMILY='ipv4'}">
                    <unicast>
                      <maximum-prefix>
                        <max-prefix-limit>{$PREFIX_LIMIT}</max-prefix-limit>
                        <threshold>{$PREFIX_THRESHOLD}</threshold>
                      </maximum-prefix>
                    </unicast>
                  </ipv4>
                  <ipv6 when="{$ADDRESS_FAMILY='ipv6'}">
                    <unicast>
                      <maximum-prefix>
                        <max-prefix-limit>{$PREFIX_LIMIT}</max-prefix-limit>
                        <threshold>{$PREFIX_THRESHOLD}</threshold>
                      </maximum-prefix>
                    </unicast>
                  </ipv6>
                </address-family>
              </neighbor>
            </bgp-no-instance>
          </bgp>
        </router>
      </config>
    </device>
  </devices>
</config-template>
```

As you can see, I have the 'ipv6' as well in the above template with the 'when', so this either of the address-family neighbor configuration will be present, depending on the user input. 

You can also notice that all the variables coming from the python script we edited in the form of `{$<var>}`, e.g. `{$NEIGHBOR_ADDRESS}`. 

As we have edited all of the three files, final step will be to compile this package and check if there are any errors. 

__Step5: Compile the python-and-template service package__

To make the service package in NSO is very easy as there is always a Makefile available under the `${NCS_RUN_DIR}/packages/bgp-prefix-limit-service/src/`. So we can run this file to compile the package. 

```sh
root@cisco-nso-dev:~# cd ${NCS_RUN_DIR}/packages/bgp-prefix-limit-service/src/
root@cisco-nso-dev:~/ncs-instance/packages/bgp-prefix-limit-service/src# ls -l
total 4
-rw-r--r--. 1 root root 726 Jul 11 09:06 Makefile
drwxr-xr-x. 2 root root  43 Jul 11 09:57 yang
root@cisco-nso-dev:~/ncs-instance/packages/bgp-prefix-limit-service/src# 
```

To compile this package, go to `${NCS_RUN_DIR}/packages/bgp-prefix-limit-service/src/` and run `make clean && make`.

```
root@cisco-nso-dev:~/ncs-instance/packages/bgp-prefix-limit-service/src# make clean && make
rm -rf ../load-dir
mkdir -p ../load-dir
/root/nso-6.3/bin/ncsc  `ls bgp-prefix-limit-service-ann.yang  > /dev/null 2>&1 && echo "-a bgp-prefix-limit-service-ann.yang"` \
        --fail-on-warnings \
         \
        -c -o ../load-dir/bgp-prefix-limit-service.fxs yang/bgp-prefix-limit-service.yang
root@cisco-nso-dev:~/ncs-instance/packages/bgp-prefix-limit-service/src# 
```

As you can see no errors found during the compilation of this package, now we can go to the NSO and reload the package to check if there any errors. 


```sh
root@cisco-nso-dev:~/ncs-instance/packages/bgp-prefix-limit-service/src# ncs_cli -C -u admin

User admin last logged in 2024-07-11T10:00:40.27344+00:00, to cisco-nso-dev, from 127.0.0.1 using cli-console
admin connected from 127.0.0.1 using console on cisco-nso-dev
admin@ncs# packages reload 

>>> System upgrade is starting.
>>> Sessions in configure mode must exit to operational mode.
>>> No configuration changes can be performed until upgrade has completed.
>>> System upgrade has completed successfully.
reload-result {
    package bgp-prefix-limit-service
    result true
}
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
System message at 2024-07-11 10:36:38...
    Subsystem stopped: ncs-dp-37-cisco-asa-cli-6.18:ASADp
admin@ncs# 
System message at 2024-07-11 10:36:38...
    Subsystem stopped: ncs-dp-38-cisco-ios-cli-6.106:IOSDp
admin@ncs# 
System message at 2024-07-11 10:36:38...
    Subsystem stopped: ncs-dp-39-cisco-nx-cli-5.25:NexusDp
admin@ncs# 
System message at 2024-07-11 10:36:38...
    Subsystem started: ncs-dp-40-cisco-asa-cli-6.18:ASADp
admin@ncs# 
System message at 2024-07-11 10:36:38...
    Subsystem started: ncs-dp-41-cisco-ios-cli-6.106:IOSDp
admin@ncs# 
System message at 2024-07-11 10:36:38...
    Subsystem started: ncs-dp-42-cisco-nx-cli-5.25:NexusDp
admin@ncs# 
```

See the the following from the above output, which package has successfully been created and reloading package shows no errors.

```sh 
reload-result {
    package bgp-prefix-limit-service
    result true
}
```

__Step6: Test python-and-template service package__

Moment of truth, Let's test our package by creating a new neighbor and set the maximu prefix limit

```sh

admin@ncs(config)# bgp-prefix-limit-service bgp-service-1 device cml-core-rtr01 neighbors 1.1.1.1 remote-as 200 description "created by nso" ipv4-unicast prefix-limit 200 prefix-threshold 75 
admin@ncs(config-neighbors-1.1.1.1)# commit dry-run 
cli {
    local-node {
        data  devices {
                  device cml-core-rtr01 {
                      config {
                          router {
                              bgp {
                                  bgp-no-instance 65001 {
             +                        neighbor 1.1.1.1 {
             +                            remote-as 200;
             +                            description "created by nso";
             +                            address-family {
             +                                ipv4 {
             +                                    unicast {
             +                                        maximum-prefix {
             +                                            max-prefix-limit 200;
             +                                            threshold 75;
             +                                        }
             +                                    }
             +                                }
             +                            }
             +                        }
                                  }
                              }
                          }
                      }
                  }
              }
             +bgp-prefix-limit-service bgp-service-1 {
             +    device cml-core-rtr01;
             +    neighbors 1.1.1.1 {
             +        description "created by nso";
             +        remote-as 200;
             +        ipv4-unicast;
             +        prefix-limit 200;
             +        prefix-threshold 75;
             +    }
             +}
    }
}
admin@ncs(config-neighbors-1.1.1.1)# commit label ad-nei-core01
Commit complete.
admin@ncs(config-neighbors-1.1.1.1)# 
```

Now let's check on the cml-core-rtr01. 

```sh
RP/0/RP0/CPU0:cml-core-rtr01#sh run router bgp 65001 neighbor 1.1.1.1
Thu Jul 11 10:41:16.979 UTC
router bgp 65001
 neighbor 1.1.1.1
  remote-as 200
  description created by nso
  address-family ipv4 unicast
   maximum-prefix 200 75
  !
 !
!

```

Here you go, you have successfully created a service package using python-and-template.

For clean up, we can rollback the configuation. 

```sh
admin@ncs(config-neighbors-1.1.1.1)# commit label ad-nei-core01
Commit complete.
admin@ncs(config-neighbors-1.1.1.1)# 
admin@ncs(config-neighbors-1.1.1.1)# 
admin@ncs(config-neighbors-1.1.1.1)# top
admin@ncs(config)# rollback configuration 
admin@ncs(config)# commit dry-run 
cli {
    local-node {
        data  devices {
                  device cml-core-rtr01 {
                      config {
                          router {
                              bgp {
                                  bgp-no-instance 65001 {
             -                        neighbor 1.1.1.1 {
             -                            remote-as 200;
             -                            description "created by nso";
             -                            address-family {
             -                                ipv4 {
             -                                    unicast {
             -                                        maximum-prefix {
             -                                            max-prefix-limit 200;
             -                                            threshold 75;
             -                                        }
             -                                    }
             -                                }
             -                            }
             -                        }
                                  }
                              }
                          }
                      }
                  }
              }
             -bgp-prefix-limit-service bgp-service-1 {
             -    device cml-core-rtr01;
             -    neighbors 1.1.1.1 {
             -        description "created by nso";
             -        remote-as 200;
             -        ipv4-unicast;
             -        prefix-limit 200;
             -        prefix-threshold 75;
             -    }
             -}
    }
}
admin@ncs(config)# commit
Commit complete.
admin@ncs(config)# 
```

```sh
RP/0/RP0/CPU0:cml-core-rtr01#sh run router bgp 65001 neighbor 1.1.1.1
Thu Jul 11 10:44:50.278 UTC
% No such configuration item(s)

RP/0/RP0/CPU0:cml-core-rtr01#
```

## Reference: 

_[Developing a Simple Service](https://developer.cisco.com/docs/nso/guides/developing-a-simple-service/#developing-a-simple-service)

_[Python Scripts and NSO Service Development](https://developer.cisco.com/learning/labs/service-dev-201/introduction/)_

_[Create Cisco NSO service ](https://yang-prog-lab.ciscolive.com/pod/0/nso/create_service)_

_[LABSPG-2442-LG]https://www.ciscolive.com/c/dam/r/ciscolive/emea/docs/2018/pdf/LABSPG-2442-LG.pdf_

_[YANG Guidelines](https://1.ieee802.org/yang-guidelines/)_

_[YANG - A Data Modeling Language for the Network Configuration Protocol (NETCONF) RFC 6020](https://datatracker.ietf.org/doc/rfc6020/)_
